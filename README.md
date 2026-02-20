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
