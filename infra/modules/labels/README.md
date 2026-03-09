# Module: labels

Generates a standardized labels map (mandatory taxonomy) merged with optional additional labels for GCP resources.

## Architecture / Overview

This module builds a mandatory labels taxonomy used for cost attribution and ownership, then merges it with any optional `additional_labels`. Mandatory keys are `team`, `model`, `env`, and `managed-by` (mapped from `managed_by`). The module validates lowercase values when `enforce_lowercase_values` is enabled and prevents `additional_labels` from redefining mandatory keys.

## Example Usage

```hcl
module "example" {
  source = "../../modules/labels"

  team    = "recommendations"
  model   = "bumble-dna"
  env     = "dev"

  # optional
  managed_by              = "mlops-platform"
  additional_labels       = { owner = "alice" }
  enforce_lowercase_values = true
}
```

## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.5 |

## Providers

| Name | Version |
| ---- | ------- |
| google | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| `team` | Owning ML team used for cost attribution and operational ownership. | string | — | yes |
| `model` | Model identifier for cost tracking (controlled enum; extendable). | string | — | yes |
| `env` | Deployment environment. | string | — | yes |
| `managed_by` | Ownership label indicating the managing platform/team. | string | "mlops-platform" | no |
| `additional_labels` | Optional additional labels to merge with the mandatory taxonomy. | map(string) | {} | no |
| `enforce_lowercase_values` | If true, validates that mandatory label values are lowercase. | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| `labels` | Merged labels map including mandatory taxonomy labels and any additional_labels. |
| `mandatory_labels` | Mandatory taxonomy labels only. |

## Module Structure

modules/labels/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md

## Notes

- Mandatory label keys: `team`, `model`, `env`, and `managed-by` (the variable is `managed_by`, but the label key is `managed-by`).
- `additional_labels` must not redefine mandatory keys; this is validated by the module.
- By default `enforce_lowercase_values = true`; set to `false` to disable lowercase validation for mandatory values.
- `merged_labels` is produced by merging the mandatory taxonomy with `additional_labels`.

