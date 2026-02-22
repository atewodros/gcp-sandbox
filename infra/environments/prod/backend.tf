terraform {
  backend "gcs" {
    bucket = "atewodros-prod-tfstate" # TODO: replace with bootstrap output bucket name
    prefix = "terraform"
  }
}
