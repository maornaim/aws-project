# DevOps Dashboard

End-to-end DevOps project that deploys a containerized Flask application to Amazon EKS and connects it to a private PostgreSQL database on Amazon RDS.

The project demonstrates Infrastructure as Code, secure CI/CD, GitOps deployment, Kubernetes operations, monitoring and autoscaling.

## What this project demonstrates

- Provisioning AWS infrastructure with Terraform
- Running a Flask application on Amazon EKS
- Connecting EKS workloads to private Amazon RDS PostgreSQL
- Building and publishing Docker images to GHCR
- Automating Terraform through GitHub Actions
- Authenticating GitHub Actions to AWS with OIDC
- Deploying Kubernetes manifests with Argo CD
- Monitoring the cluster and application with Prometheus and Grafana
- Scaling the application with Kubernetes HPA
- Running integration and smoke tests in the delivery process

## Architecture

```text
Git push to main
        |
        v
GitHub Actions
  1. Integration tests
  2. Terraform plan and apply
  3. Docker image build and publish
  4. Kubernetes image manifest update
        |
        v
Argo CD
  GitOps synchronization
        |
        v
Amazon EKS
  Flask application, HPA and monitoring
        |
        v
Private Amazon RDS PostgreSQL
```

## Technology stack

| Area | Technologies |
|---|---|
| Cloud | AWS, VPC, EKS, EC2, RDS, S3, IAM, Secrets Manager |
| Infrastructure | Terraform |
| Application | Python, Flask, PostgreSQL |
| Containers | Docker, GHCR |
| CI/CD | GitHub Actions |
| GitOps | Argo CD |
| Kubernetes | Deployments, Services, Jobs, ConfigMaps, Secrets, HPA |
| Monitoring | Prometheus, Grafana, Metrics Server |
| Packaging | Helm |

## AWS infrastructure

Terraform manages:

- VPC with public subnets in multiple Availability Zones
- Amazon EKS cluster
- Managed node group with three `t3.small` worker nodes
- Private PostgreSQL RDS instance
- Encrypted and versioned S3 Terraform backend
- IAM roles for EKS and GitHub Actions
- GitHub OIDC identity provider

## CI/CD and GitOps

A push to `main` starts four ordered GitHub Actions jobs:

1. `test`
   - Runs Docker Compose integration tests.

2. `terraform`
   - Authenticates to AWS using OIDC.
   - Runs Terraform initialization, validation, plan and apply.

3. `build_and_publish`
   - Builds the Docker image.
   - Publishes commit-based and `latest` tags to GHCR.

4. `update_manifest`
   - Updates the image tag in `k8s/app.yaml`.
   - Pushes an automated Git commit.

Argo CD watches the `k8s/` directory and synchronizes the updated manifests to EKS.

CI does not run `kubectl apply` for application deployment. Argo CD is responsible for the Kubernetes deployment layer.

## Kubernetes workloads

The application runs as a Kubernetes Deployment with:

- Two application replicas by default
- Readiness and liveness probes
- A LoadBalancer Service
- Horizontal Pod Autoscaler with a range of two to five replicas
- Internal metrics endpoint on port `8000`

The cluster also runs Argo CD, Prometheus, Grafana, Metrics Server, kube-state-metrics and node-exporter.

## Monitoring

The application exposes Flask metrics on port `8000`.

Prometheus discovers the application through a ServiceMonitor and collects:

- Request rate
- HTTP 5xx error rate
- Response latency
- Kubernetes object metrics
- Node CPU, memory and system metrics

Grafana displays the application dashboard and cluster metrics.

## Repository structure

```text
app/
├── app.py
├── database.py
├── requirements.txt
└── templates/

database/
└── init.sql

k8s/
├── app.yaml
├── app-metrics.yaml
├── db-init-job.yaml
├── grafana-dashboard.yaml
└── hpa.yaml

terraform/
├── provider.tf
├── state.tf
├── network.tf
├── eks.tf
├── nodes.tf
├── iam.tf
├── git.tf
├── rds.tf
├── user.tf
└── outputs.tf

scripts/
├── manage.sh
├── config.sh
├── start-stop/
│   ├── start.sh
│   └── stop.sh
└── tests/
    ├── test.sh
    └── smoke.sh
```

## Running locally

Run the integration tests:

```bash
bash scripts/manage.sh -a test
```

Start or provision the AWS and EKS environment:

```bash
bash scripts/manage.sh -a start
```

Run the smoke tests:

```bash
bash scripts/manage.sh -a smoke
```

Stop the environment:

```bash
bash scripts/manage.sh -a stop
```

## Security and state management

- GitHub Actions uses short-lived AWS credentials through OIDC.
- No long-lived AWS access keys are used by GitHub Actions.
- Terraform state is stored in an encrypted, versioned S3 bucket.
- RDS is private and is not publicly accessible.
- Database credentials are stored in AWS Secrets Manager.
- Secrets, credentials, local Terraform state and the `.terraform` directory must not be committed.

## Project outcome

This project provides hands-on experience with the complete path from infrastructure provisioning to application delivery:

```text
Terraform
  -> AWS and EKS
  -> GitHub Actions
  -> Docker and GHCR
  -> Argo CD
  -> Kubernetes
  -> Prometheus and Grafana
```
