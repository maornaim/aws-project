APP_NAME="aws-project"
SERVICE_NAME="app-service"

AWS_REGION="eu-central-1"
CLUSTER_NAME="maor-devops-cluster"
DB_INSTANCE_NAME="maor-devops-postgres"

TERRAFORM_DIR="terraform"

APP_FILE="k8s/app.yaml"
DB_JOB_FILE="k8s/db-init-job.yaml"
DB_SECRET="postgres-credentials"

MONITORING_VALUES_FILE="monitoring/values.yaml"
MONITORING_VERSION="92.7.0"

METRICS_SERVER_VERSION="3.14.0"

ARGO_NAMESPACE="argocd"
ARGO_APPLICATION_FILE="argocd/application.yaml"
ARGOCD_VERSION="10.11.1"
