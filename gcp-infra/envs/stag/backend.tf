terraform {
  backend "gcs" {
    bucket = "atewodros-stag-tfstate"  # TODO: replace with bootstrap output bucket name
    prefix = "terraform"
  }
}
