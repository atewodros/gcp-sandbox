# terraform-google-ml-labels

Reusable Terraform module enforcing mandatory GCP ML label taxonomy.

## Mandatory Labels
- team
- model
- env
- managed-by

## Example Usage

module "labels" {
  source = "../terraform-google-ml-labels"

  team  = "recommendations"
  model = "wasp"
  env   = "prod"
}

resource "google_storage_bucket" "example" {
  name     = "example-bucket-12345"
  location = "US"
  labels   = module.labels.labels
}
