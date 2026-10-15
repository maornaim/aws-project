# DevOps Dashboard on AWS

פרויקט ענן מינימלי שמריץ אפליקציית Flask על Amazon EKS ושומר מידע ב־Amazon RDS for PostgreSQL.

## Architecture

```text
Git repository
      |
      v
Terraform -> VPC, EKS, EC2 nodes, RDS and S3 state
      |
      v
Kubernetes -> Flask pods -> RDS PostgreSQL
```

## Project structure

```text
app/         Flask application
database/    PostgreSQL schema
k8s/         Kubernetes manifests
terraform/   AWS infrastructure
Dockerfile   Application container image
database.py  PostgreSQL connection code
```

## Infrastructure

Terraform uses the existing remote state:

```text
s3://maor-devops-tfstate-533267148415/terraform.tfstate
```

Initialize and verify the existing infrastructure:

```bash
cd terraform
terraform init
terraform plan
```

The first plan from this directory must show no unexpected changes before applying anything.

## Connect kubectl

```bash
aws eks update-kubeconfig --region eu-central-1 --name maor-devops-cluster
kubectl get nodes
```

Both nodes should report `Ready`.

## Database credentials

RDS stores its master password in AWS Secrets Manager. Do not store the password in Git or in a YAML file.

Find the managed secret in the AWS console under:

```text
RDS -> maor-devops-postgres -> Configuration -> Master credentials ARN
```

Copy the current password from Secrets Manager, then use a hidden terminal prompt to create or update the Kubernetes Secret:

```bash
read -s -p "RDS password: " RDS_PASSWORD
echo
kubectl create secret generic postgres-credentials \
  --from-literal=POSTGRES_USER=postgres \
  --from-literal=POSTGRES_PASSWORD="$RDS_PASSWORD" \
  --from-literal=POSTGRES_DB=dashboard \
  --dry-run=client -o yaml | kubectl apply -f -
unset RDS_PASSWORD
```

The password is not saved in shell history. Do not paste command output containing the password into chat, logs, or Git.

RDS rotates the managed password periodically. Recreate the Kubernetes Secret with the current value after a rotation; a future CI/CD stage can automate this synchronization.

## Initialize the database

The Job creates the `users` table if it does not already exist:

```bash
kubectl apply -f k8s/db-init-job.yaml
kubectl get jobs
```

The Job should reach `Complete`.

## Deploy the application

```bash
kubectl apply -f k8s/app.yaml
kubectl get pods -o wide
```

The Deployment maintains two Flask pods. The Service is currently internal (`ClusterIP`) to avoid creating a paid AWS load balancer.

Test locally through the Kubernetes API connection:

```bash
kubectl port-forward service/app-service 8080:80
```

Open `http://localhost:8080` while the command is running.

## Important

Use this directory as the only Terraform source for the shared S3 state after verifying the migration. Do not run Terraform from both the old and new projects.

Do not commit passwords, AWS credentials, Kubernetes Secret manifests, local Terraform state, or the `.terraform` directory.
