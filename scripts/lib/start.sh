start_environment() {
  terraform -chdir="$TERRAFORM_DIR" apply

  aws eks update-kubeconfig \
    --name "$CLUSTER_NAME" \
    --region "$AWS_REGION"

  SECRET_ARN=$(aws rds describe-db-instances \
    --db-instance-identifier "$DB_INSTANCE_NAME" \
    --region "$AWS_REGION" \
    --query "DBInstances[0].MasterUserSecret.SecretArn" \
    --output text)

  DB_PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text |
    python -c 'import json,sys; print(json.load(sys.stdin)["password"])')

  kubectl delete secret "$DB_SECRET" --ignore-not-found

  kubectl create secret generic "$DB_SECRET" \
    --from-literal=POSTGRES_USER=postgres \
    --from-literal=POSTGRES_PASSWORD="$DB_PASSWORD" \
    --from-literal=POSTGRES_DB=dashboard

  kubectl apply -f "$DB_JOB_FILE"
  kubectl wait --for=condition=complete job/db-init --timeout=180s

  helm upgrade --install monitoring \
    oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --version "$MONITORING_VERSION" \
    --values "$MONITORING_VALUES_FILE" \
    --wait \
    --timeout 5m

  helm repo add metrics-server \
    https://kubernetes-sigs.github.io/metrics-server/ \
    --force-update

  helm upgrade --install metrics-server \
    metrics-server/metrics-server \
    --namespace kube-system \
    --version "$METRICS_SERVER_VERSION" \
    --wait \
    --timeout 5m

  helm upgrade --install argocd \
    oci://ghcr.io/argoproj/argo-helm/argo-cd \
    --namespace "$ARGO_NAMESPACE" \
    --create-namespace \
    --version "$ARGOCD_VERSION" \
    --wait \
    --timeout 5m

  kubectl apply -f "$ARGO_APPLICATION_FILE"
  kubectl wait --for=jsonpath='{.status.sync.status}'=Synced application/"$APP_NAME" -n "$ARGO_NAMESPACE" --timeout=300s
  kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/"$APP_NAME" -n "$ARGO_NAMESPACE" --timeout=300s

  kubectl get service "$SERVICE_NAME"
}
