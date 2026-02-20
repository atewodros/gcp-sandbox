terraform {
  backend "gcs" {
    bucket = "atewodros-sandbox-tfstate"  # TODO: replace with bootstrap output bucket name
    prefix = "terraform"
  }
}
