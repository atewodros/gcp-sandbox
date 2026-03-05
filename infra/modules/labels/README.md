# Enterprise Labels Module (GCP + Terraform)

This module generates a **GCP label-compliant** map using a recommended “enterprise” label set.

It includes **Terraform variable validations** to enforce:
- allowed environments
- allowed compliance/data-classification values
- GCP label naming rules (lowercase, 63 chars max, `a-z0-9_-`)

## Recommended Enterprise Label Set

| Key | Purpose | Example |
|---|---|---|
| `environment` | environment grouping | `sandbox` / `stag` / `prod` |
| `project` | logical project grouping | `gcp-sandbox` |
| `owner` | owning team/person | `atewodros` |
| `team` | engineering team | `devops` |
| `service` | app/service name | `hello` |
| `cost_center` | billing grouping | `engineering` |
| `compliance` | regulatory classification | `none` / `pci` / `hipaa` / `sox` / `gdpr` |
| `data_classification` | sensitivity | `public` / `internal` / `restricted` |
| `managed_by` | IaC tool | `terraform` |

## Files

- `variables.tf` – inputs + validation rules
- `main.tf` – `locals` that build the labels map
- `outputs.tf` – `labels` output
- `versions.tf` – requires Terraform >= 1.6

---

## Usage

### Basic
```hcl
module "labels" {
  source  = "../../modules/labels"

  project = "gcp-sandbox"
  env     = var.env
  owner   = "atewodros"

  team    = "devops"
  service = "platform"
}
```

### Add extra labels
```hcl
module "labels" {
  source  = "../../modules/labels"
  project = "gcp-sandbox"
  env     = var.env
  owner   = "atewodros"

  extra_labels = {
    repo = "gcp-sandbox"
  }
}
```

---

## Apply labels in common cases

### Case A: Provider `default_labels` (recommended)
This automatically labels **most** supported resources.

```hcl
provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = module.labels.labels
}
```

> Note: Some resources use different fields or don’t support labels; see “Manual fields” below.

---

### Case B: Resource supports `labels`
Examples include Cloud Run, Artifact Registry, subnets, storage buckets, etc.

```hcl
resource "google_cloud_run_v2_service" "svc" {
  project  = var.project_id
  location = var.region
  name     = "${var.env}-hello"

  labels = module.labels.labels

  template {
    containers {
      image = var.image
    }
  }
}
```

---

## Manual fields (important)

Some resources require **non-standard label fields** or special placement:

### 1) GKE Cluster: `resource_labels`
```hcl
resource "google_container_cluster" "cluster" {
  project  = var.project_id
  name     = "${var.env}-gke"
  location = var.zone

  resource_labels = module.labels.labels
}
```

### 2) GKE Node Pool: `node_config.labels`
```hcl
resource "google_container_node_pool" "default" {
  project  = var.project_id
  cluster  = google_container_cluster.cluster.name
  location = var.zone
  name     = "default-pool"

  node_config {
    labels = module.labels.labels
  }
}
```

### 3) Project labels: `google_project.labels`
If the project already exists, **import it first**.
```hcl
resource "google_project" "this" {
  project_id = var.project_id
  name       = var.project_id

  labels = module.labels.labels
}
```

Import example:
```bash
terraform import google_project.this atewodros-sandbox
```

---

## Resources that do NOT support labels
Some resources (example: `google_compute_network` VPC) do not support a `labels` argument.
Terraform will fail if you try to set labels where unsupported.

---

## Validation behavior
If you pass invalid values (example: `env = "dev"`), Terraform will fail during `validate/plan` with a clear error message.

---

## Outputs
- `module.labels.labels` – map(string) to apply to resources
- `module.labels.required_keys` – list of recommended keys
