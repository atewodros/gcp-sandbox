# CI/CD Pipeline

GitHub Actions deploys infrastructure and workloads.

Pipeline stages:

1. terraform fmt
2. terraform validate
3. terraform plan
4. terraform apply

Deployment flow:

sandbox → stag → prod

Production requires manual approval.