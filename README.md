# GCP Multi-Env Platform (Terraform) — Best-Practice Layout

This repo uses a **bootstrap + environments + modules** structure:

- `infra/bootstrap/` — one-time setup (projects, APIs, state buckets, GitHub OIDC/WIF)
- `infra/environments/<env>/` — environment stacks (sandbox/stag/prod), each with its own backend/state
- `infra/modules/` — reusable modules (network, gke, artifact registry, cloud run, iam, github_wif)

The rest of the repo contains GitHub Actions workflows and a sample Cloud Run app (`app/`).

---
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



## How to Find Your Billing Account ID, Org ID, or Folder ID

These values are required for the **bootstrap** step when creating new GCP projects.

### Find Billing Account ID

#### Option 1: Using Google Cloud Console
1. Go to: https://console.cloud.google.com/billing
2. Select your billing account.
3. The **Billing Account ID** appears at the top (format: `000000-000000-000000`).

#### Option 2: Using gcloud CLI
```powershell
gcloud billing accounts list
```
The output will show:
```
ACCOUNT_ID            NAME                OPEN
000000-000000-000000  My Billing Account  True
```

Use the `ACCOUNT_ID` value.

---

### Find Organization ID

#### Option 1: Using gcloud CLI
```powershell
gcloud organizations list
```
Output example:
```
DISPLAY_NAME        ID
example.com         123456789012
```

Use the numeric `ID` value as your `org_id`.

#### Option 2: Using Console
Go to:
https://console.cloud.google.com/iam-admin/settings

The Organization ID appears at the top of the page.

---

### Find Folder ID (if using folders instead of org root)

#### Using gcloud CLI
```powershell
gcloud resource-manager folders list
```
Example output:
```
DISPLAY_NAME     ID
Dev Folder       345678901234
```

Use the numeric `ID` value as your `folder_id`.

---

### Which one should you use?

- If your company uses an **Organization**, use `org_id`.
- If projects must be created inside a **specific folder**, use `folder_id` instead.
- You only need **one**: either `org_id` OR `folder_id`.

Example in `terraform.tfvars`:

```hcl
billing_account_id = "000000-000000-000000"
org_id             = "123456789012"
# folder_id        = "345678901234"
```


---
# GitHub CLI & CI/CD (Workload Identity Federation)

## Install GitHub CLI (Windows PowerShell)
```powershell
choco install gh -y
gh auth login
```

## Push Terraform bootstrap outputs to GitHub Secrets
```powershell
cd infra\bootstrap
terraform output -json env > env.json
$repo = "atewodros/gcp-sandbox"
$envs = Get-Content .\env.json | ConvertFrom-Json

gh secret set GCP_WIF_PROVIDER_sandbox --repo $repo --body $envs.sandbox.wif_provider
gh secret set GCP_TF_SA_sandbox       --repo $repo --body $envs.sandbox.tf_deployer_sa_email
gh secret set GCP_WIF_PROVIDER_stag   --repo $repo --body $envs.stag.wif_provider
gh secret set GCP_TF_SA_stag          --repo $repo --body $envs.stag.tf_deployer_sa_email
gh secret set GCP_WIF_PROVIDER_prod   --repo $repo --body $envs.prod.wif_provider
gh secret set GCP_TF_SA_prod          --repo $repo --body $envs.prod.tf_deployer_sa_email
gh secret set GCP_PROJECT_ID_STAG     --repo $repo --body "atewodros-stag"
```

Verify:
```powershell
gh secret list --repo atewodros/gcp-sandbox
```

---
# Workload Identity Federation Troubleshooting

Correct provider format:
```
projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-ENV/providers/github
```

Check providers:
```powershell
gcloud iam workload-identity-pools providers list --project atewodros-stag --location=global --workload-identity-pool=github-stag
```

---
# Windows Authentication Fix (ADC Path)

```powershell
gcloud auth application-default login
$env:GOOGLE_APPLICATION_CREDENTIALS="<ADC_PATH>"
```

---
# Git Line Endings (Windows)

```powershell
git config --global core.autocrlf true
```



# GCP Sandbox – Terraform + GKE + Cloud Run + CI/CD

This repository provisions a multi-environment Google Cloud setup using Terraform.

Environments:
- sandbox
- stag
- prod

Region:
- us-east1

---

# Architecture Overview

Each environment provisions:

- VPC + Subnet
- GKE Cluster (Standard)
- Dedicated Node Pool (30GB pd-standard)
- Cloud Run Service
- Artifact Registry (Docker)
- IAM + Service Accounts
- GitHub Workload Identity Federation (OIDC)
- Remote Terraform state (GCS)

---

# Estimated Monthly Cost (Per Environment)

Main cost drivers:

| Resource | Estimated Monthly |
|-----------|-------------------|
| GKE Cluster Fee ($0.10/hr) | ~$73 |
| 1x e2-medium Node | ~$25–40 |
| 30GB pd-standard Disk | ~$1–2 |
| Cloud Run | ~$0 (low traffic) |
| Artifact Registry | Minimal (depends on stored images) |

Estimated total per environment: ~$100–120/month

Running sandbox + stag + prod ≈ ~$300–360/month.

To see exact billing:
Billing → Reports → Filter by project.

---

# How to Check What Exists

## Terraform State
terraform state list

## All GCP Resources
gcloud asset search-all-resources --scope=projects/atewodros-sandbox

## GKE
gcloud container clusters list --project atewodros-sandbox
gcloud container node-pools list --cluster sandbox-gke --region us-east1 --project atewodros-sandbox

## Cloud Run
gcloud run services list --region us-east1 --project atewodros-sandbox

---

# Common Issues & Fixes

## 1. Artifact Registry API 403
Enable API:
gcloud services enable artifactregistry.googleapis.com --project atewodros-sandbox

## 2. GKE SSD Quota Exceeded
Fix:
- remove_default_node_pool = true
- disk_type = "pd-standard"
- disk_size_gb = 30

If cluster is corrupted:
gcloud container clusters delete sandbox-gke --region us-east1 --project atewodros-sandbox

Then:
terraform state rm module.gke.google_container_cluster.cluster
terraform apply

## 3. Node Pool Already Exists
terraform state rm module.gke.google_container_node_pool.default
terraform import module.gke.google_container_node_pool.default projects/atewodros-sandbox/locations/us-east1/clusters/sandbox-gke/nodePools/default-pool

---

# GitHub Actions CI/CD

Workflow order:
- sandbox
- stag (runs only if sandbox succeeds)
- prod (runs only if stag succeeds)

Push → runs sandbox only.
Manual dispatch → runs full promotion chain.

Required Secrets:

GCP_WIF_PROVIDER_SANDBOX
GCP_TF_SA_SANDBOX
GCP_WIF_PROVIDER_STAG
GCP_TF_SA_STAG
GCP_WIF_PROVIDER_PROD
GCP_TF_SA_PROD
TF_VAR_cloud_run_image_SANDBOX
TF_VAR_cloud_run_image_STAG
TF_VAR_cloud_run_image_PROD

Set via CLI:

gh secret set TF_VAR_cloud_run_image_SANDBOX --body "us-docker.pkg.dev/cloudrun/container/hello:latest"

---

# Cleanup (Stop Spending)

To delete sandbox environment:

terraform destroy -auto-approve

Or delete cluster only:

gcloud container clusters delete sandbox-gke --region us-east1 --project atewodros-sandbox

---

# Best Practices

- Use remote backend (GCS)
- Use Workload Identity Federation (no service account keys)
- Use TF_VAR secrets in GitHub
- Separate environments
- Keep sandbox minimal to control cost

---

You now have a production-style multi-env Terraform + GCP pipeline.
