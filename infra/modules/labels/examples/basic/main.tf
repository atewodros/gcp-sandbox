provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

module "labels" {
  source = "../../"

  team  = "recommendations"
  model = "wasp"
  env   = "prod"

  additional_labels = {
    service = "recs-inference"
  }
}

resource "google_storage_bucket" "example" {
  name     = "example-bucket-with-labels-12345"
  location = "US"

  labels = module.labels.labels
}
