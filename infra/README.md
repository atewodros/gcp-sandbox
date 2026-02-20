# Terraform Infrastructure

## Layout
- `bootstrap/` — creates projects (sandbox/stag/prod), enables APIs, creates TF state buckets, and sets up GitHub OIDC (WIF).
- `environments/` — per-environment stacks with isolated backends/state.
- `modules/` — reusable Terraform modules.

## Bootstrap (one-time)
```powershell
cd infra\bootstrap
terraform init
terraform apply
```

After bootstrap:
1. Update backend buckets in:
   - `infra/environments/sandbox/backend.tf`
   - `infra/environments/stag/backend.tf`
   - `infra/environments/prod/backend.tf`
2. Add GitHub Secrets from bootstrap output (see root README).

## Apply an environment
```powershell
cd infra\environments\sandbox
terraform init
terraform apply
```

## Best practices
- Keep prod applies gated (GitHub Environments / approvals).
- Prefer OIDC/WIF (no long-lived JSON keys).
- Use separate projects per environment.
