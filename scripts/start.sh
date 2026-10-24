#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

terraform -chdir=terraform apply

aws eks update-kubeconfig \
  --name maor-devops-cluster \
  --region eu-central-1

SECRET_ARN=$(aws rds describe-db-instances \
  --db-instance-identifier maor-devops-postgres \
  --region eu-central-1 \
  --query "DBInstances[0].MasterUserSecret.SecretArn" \
  --output text)

DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region eu-central-1 \
  --query SecretString \
  --output text |
  python -c 'import json,sys; print(json.load(sys.stdin)["password"])')

kubectl delete secret postgres-credentials --ignore-not-found

kubectl create secret generic postgres-credentials \
  --from-literal=POSTGRES_USER=postgres \
  --from-literal=POSTGRES_PASSWORD="$DB_PASSWORD" \
  --from-literal=POSTGRES_DB=dashboard

kubectl apply -f k8s/db-init-job.yaml
kubectl wait --for=condition=complete job/db-init --timeout=180s

helm upgrade --install monitoring \
  oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --version 92.7.0 \
  --values monitoring/values.yaml \
  --wait \
  --timeout 5m

helm upgrade --install argocd \
  oci://ghcr.io/argoproj/argo-helm/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 10.11.1 \
  --wait \
  --timeout 5m

kubectl apply -f argocd/application.yaml
kubectl wait --for=jsonpath='{.status.sync.status}'=Synced application/aws-project -n argocd --timeout=300s
kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/aws-project -n argocd --timeout=300s

kubectl get service app-service
