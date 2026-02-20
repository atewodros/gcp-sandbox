# GCP Sandbox Platform (Terraform) — sandbox / stag / prod

This repo includes:
- **bootstrap** Terraform: creates 3 GCP projects (sandbox/stag/prod), enables APIs, creates per-env TF state buckets, and configures **GitHub OIDC Workload Identity Federation (WIF)** for keyless CI/CD.
- **envs** Terraform: per-environment infrastructure including **VPC**, **GKE (Workload Identity enabled)**, **Artifact Registry**, and **Cloud Run**.
- **GitHub Actions** workflows:
  - `terraform.yml` runs fmt/validate/plan on PRs and applies on `main`.
  - `deploy-cloudrun.yml` builds and deploys a sample app to Cloud Run (staging by default).

> Region defaults to **us-east1**. Repo owner/repo is preset to **atewodros/gcp-sandbox**.

## Prereqs
- Terraform >= 1.6
- gcloud SDK
- You must know:
  - **Billing Account ID**
  - **Org ID** OR **Folder ID**

## Quick start (local, PowerShell)
1. Login and set up ADC:
   ```powershell
   gcloud auth login
   gcloud auth application-default login
   ```

2. Bootstrap (creates projects, state buckets, WIF):
   ```powershell
   cd gcp-infra\bootstrap
   terraform init
   terraform apply
   ```
   Fill in `gcp-infra/bootstrap/terraform.tfvars` first.

3. Copy the bootstrap output values into:
   - `gcp-infra/envs/*/backend.tf` bucket names
   - GitHub repo **Secrets** (see below)

4. Deploy env infra:
   ```powershell
   cd ..\envs\sandbox
   terraform init
   terraform apply
   ```

## GitHub Secrets
After `bootstrap` apply, set these secrets in GitHub:
- `GCP_WIF_PROVIDER_sandbox`, `GCP_TF_SA_sandbox`
- `GCP_WIF_PROVIDER_stag`, `GCP_TF_SA_stag`
- `GCP_WIF_PROVIDER_prod`, `GCP_TF_SA_prod`
- `GCP_PROJECT_ID_STAG` (e.g. `atewodros-stag`) for Cloud Run deploy workflow

## Notes
- `envs/*/backend.tf` contains placeholder bucket names — update them after bootstrap.
- Cloud Run is set to **public** (allUsers invoker) per your preference.


## Push this template to GitHub (Windows / PowerShell)
After downloading and extracting the zip:

```powershell
cd C:\src\gcp-sandbox
git init
git add .
git commit -m "Initial Terraform multi-env platform (bootstrap + GKE + Cloud Run + AR + GitHub OIDC)"
git branch -M main
git remote add origin https://github.com/atewodros/gcp-sandbox.git
git push -u origin main
```

## After running bootstrap → configure GitHub Secrets

Run bootstrap first:

```powershell
cd gcp-infra\bootstrap
terraform init
terraform apply
```

Terraform will output a map called **env** that contains:
- project IDs
- Terraform state bucket names
- Workload Identity Provider strings
- Terraform deployer service account emails

### Update Terraform backends
Replace bucket names in:
- gcp-infra/envs/sandbox/backend.tf
- gcp-infra/envs/stag/backend.tf
- gcp-infra/envs/prod/backend.tf

### Add GitHub Repository Secrets
GitHub → Repo → Settings → Secrets → Actions

Create:
- GCP_WIF_PROVIDER_sandbox
- GCP_TF_SA_sandbox
- GCP_WIF_PROVIDER_stag
- GCP_TF_SA_stag
- GCP_WIF_PROVIDER_prod
- GCP_TF_SA_prod
- GCP_PROJECT_ID_STAG = atewodros-stag

After this, pushing to main will run Terraform automatically.


## Install or upgrade Terraform + Google Cloud SDK (PowerShell)

### Chocolatey (recommended)
Run **PowerShell as Administrator**.

Install or upgrade Terraform (latest available in Chocolatey):
```powershell
choco upgrade terraform -y
terraform -v
```

Install or upgrade Google Cloud SDK (gcloud) (Chocolatey package name is `gcloudsdk`):
```powershell
choco upgrade gcloudsdk -y
gcloud -v
```

First-time GCP auth for Terraform (ADC):
```powershell
gcloud init
gcloud auth application-default login
```

### Pin Terraform to a specific version (optional)
If you want a fixed Terraform version (recommended for reproducible builds):
```powershell
# List versions available in Chocolatey
choco list terraform --all

# Install/upgrade a specific version (example)
choco upgrade terraform --version=1.7.5 -y

# Prevent accidental upgrades
choco pin add -n=terraform
```

### If Chocolatey can’t find gcloudsdk: use Winget fallback
```powershell
winget install -e --id Google.CloudSDK
gcloud -v
```



## Google Cloud CLI & Tutorials

### Command-line tools and client libraries
- Learn more about Google Cloud CLI commands: https://cloud.google.com/sdk/gcloud
- Accessing services with the gcloud CLI: https://cloud.google.com/sdk/docs
- Client Libraries Explained: https://cloud.google.com/apis/docs/client-libraries-explained

### Tutorials to get started
- Build and deploy a web service to Cloud Run: https://cloud.google.com/run/docs/quickstarts
- Launch large compute clusters on Compute Engine: https://cloud.google.com/compute/docs/quickstarts
- Store data on Cloud Storage: https://cloud.google.com/storage/docs/quickstart-gcloud
- Analyze Big Data with BigQuery: https://cloud.google.com/bigquery/docs/quickstarts
- Manage MySQL databases with Cloud SQL: https://cloud.google.com/sql/docs/mysql/quickstart
- Get started with Cloud DNS: https://cloud.google.com/dns/docs/quickstart



## Terraform CLI & Tutorials

### Command-line tools and documentation
- Terraform CLI documentation: https://developer.hashicorp.com/terraform/cli
- Terraform language documentation (HCL, resources, expressions): https://developer.hashicorp.com/terraform/language
- Terraform providers (including Google): https://registry.terraform.io/
- Google provider docs: https://registry.terraform.io/providers/hashicorp/google/latest/docs

### Helpful Terraform commands (quick reference)
```powershell
# Initialize (and download/update providers/modules)
terraform init
terraform init -upgrade

# Format and validate
terraform fmt -recursive
terraform validate

# Plan and apply
terraform plan
terraform plan -out=tfplan
terraform apply tfplan

# Destroy resources
terraform destroy

# Inspect state
terraform state list
terraform state show <address>

# Useful troubleshooting
terraform providers
terraform version
```

### Tutorials to get started
- Terraform on Google Cloud (HashiCorp learn): https://developer.hashicorp.com/terraform/tutorials/gcp-get-started
- Terraform Google provider examples: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
- Terraform best practices (HashiCorp): https://developer.hashicorp.com/terraform/tutorials/cli

