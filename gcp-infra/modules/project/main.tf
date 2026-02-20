variable "env" { type = string }
variable "project_id" { type = string }
variable "project_name" { type = string }
variable "billing_account_id" { type = string }
variable "org_id" { type = string, default = null }
variable "folder_id" { type = string, default = null }
variable "services" { type = list(string) }
variable "state_bucket_region" { type = string }

resource "google_project" "p" {
  project_id      = var.project_id
  name            = var.project_name
  billing_account = var.billing_account_id

  org_id    = var.folder_id == null ? var.org_id : null
  folder_id = var.folder_id
}

resource "google_project_service" "svc" {
  for_each           = toset(var.services)
  project            = google_project.p.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_storage_bucket" "tf_state" {
  name                        = "${var.project_id}-tfstate"
  location                    = var.state_bucket_region
  uniform_bucket_level_access = true
  versioning { enabled = true }

  lifecycle_rule {
    action { type = "Delete" }
    condition { num_newer_versions = 10 }
  }
}

output "project_id"      { value = google_project.p.project_id }
output "tf_state_bucket" { value = google_storage_bucket.tf_state.name }
