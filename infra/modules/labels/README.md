# gcp_ml_labels

Enforces the mandatory GCP label taxonomy for ML resources.

---

## Mandatory taxonomy

| Key        | Allowed values |
|------------|----------------|
| team       | trust-safety, recommendations |
| model      | curated allowlist (default: wasp, bumble-dna) |
| env        | dev, staging, prod |
| managed-by | mlops-platform |

---

## Module Structure

```
modules/gcp_ml_labels/
  ├── versions.tf
  ├── variables.tf
  ├── main.tf
  ├── outputs.tf
  └── README.md
```

---

## versions.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

```

---

## variables.tf

```hcl
variable "team" {
  description = "Owning team for the resource."
  type        = string

  validation {
    condition     = contains(["trust-safety", "recommendations"], var.team)
    error_message = "team must be one of: trust-safety, recommendations."
  }
}

variable "model" {
  description = "Model identifier (curated allowlist)."
  type        = string

  validation {
    condition     = length(var.model) > 0
    error_message = "model must be a non-empty string."
  }
}

variable "env" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "managed_by" {
  description = "Enforced constant to indicate platform ownership."
  type        = string
  default     = "mlops-platform"

  validation {
    condition     = var.managed_by == "mlops-platform"
    error_message = "managed_by must be exactly: mlops-platform."
  }
}

variable "allowed_models" {
  description = "Allowlist of approved model label values. Extend via PR."
  type        = set(string)
  default     = ["wasp", "bumble-dna"]
}

variable "extra_labels" {
  description = "Optional additional labels (mandatory labels always win)."
  type        = map(string)
  default     = {}
}

```

---

## main.tf

```hcl
locals {
  reserved_keys = toset(["team", "model", "env", "managed-by", "managed_by"])

  mandatory_labels = {
    team       = var.team
    model      = var.model
    env        = var.env
    managed-by = var.managed_by
  }

  extra_label_keys        = toset(keys(var.extra_labels))
  reserved_keys_in_extras = setintersection(local.extra_label_keys, local.reserved_keys)
  extras_do_not_override  = length(local.reserved_keys_in_extras) == 0

  model_allowed = contains(var.allowed_models, var.model)

  labels = merge(var.extra_labels, local.mandatory_labels)
}

resource "terraform_data" "label_guard" {
  input = local.labels

  lifecycle {
    precondition {
      condition     = local.model_allowed
      error_message = "model must be one of allowed_models."
    }

    precondition {
      condition     = local.extras_do_not_override
      error_message = "extra_labels must not include reserved keys."
    }
  }
}

```

---

## outputs.tf

```hcl
output "labels" {
  description = "Merged labels map to apply to all resources."
  value       = local.labels
}

output "mandatory_labels" {
  description = "Only the mandatory labels."
  value       = local.mandatory_labels
}

```

---

## Usage Example at resource level

```hcl
module "labels" {
  source = "./modules/gcp_ml_labels"

  team  = "trust-safety"
  model = "wasp"
  env   = "prod"

  extra_labels = {
    cost-center = "ml"
    component   = "feature-store"
  }
}

resource "google_storage_bucket" "artifacts" {
  name   = "ml-artifacts-prod"
  labels = module.labels.labels
}
```

---


## Guarantees

- Fails if team/env invalid  
- Fails if model not in allowlist  
- Fails if extra_labels override reserved keys  
- Ensures managed-by = mlops-platform
