# Labeling Strategy

Labels enable governance, cost allocation, and automation.

## Standard Enterprise Labels

- environment
- owner
- team
- service
- cost_center
- managed_by

## Terraform Example

module "labels" {
  source = "../../modules/labels"

  project = "gcp-sandbox"
  env     = var.env
  owner   = "atewodros"
}

labels = module.labels.common_labels