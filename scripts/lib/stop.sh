stop_environment() {
  kubectl delete application "$APP_NAME" -n "$ARGO_NAMESPACE" --ignore-not-found
  kubectl delete -f "$APP_FILE" --ignore-not-found
  kubectl delete -f "$DB_JOB_FILE" --ignore-not-found
  kubectl delete secret "$DB_SECRET" --ignore-not-found

  terraform -chdir="$TERRAFORM_DIR" destroy \
    -target=aws_eks_node_group.main \
    -target=aws_eks_cluster.main \
    -target=aws_db_instance.postgres
}
