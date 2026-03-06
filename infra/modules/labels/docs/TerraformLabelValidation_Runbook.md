# Terraform Label Validation Runbook

## Purpose
Ensure all Terraform modules apply the enterprise label set.

## Validate Terraform state
terraform state list

Inspect labels on a resource:

terraform state show module.network.google_compute_network.vpc

## Validate module output
terraform console
module.labels.common_labels

## Best practice
Always pass labels from the labels module:

labels = module.labels.common_labels