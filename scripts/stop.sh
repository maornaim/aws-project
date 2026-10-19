#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

kubectl delete -f k8s/app.yaml --ignore-not-found
kubectl delete -f k8s/db-init-job.yaml --ignore-not-found
kubectl delete secret postgres-credentials --ignore-not-found

terraform -chdir=terraform destroy \
  -target=aws_eks_node_group.main \
  -target=aws_eks_cluster.main \
  -target=aws_db_instance.postgres