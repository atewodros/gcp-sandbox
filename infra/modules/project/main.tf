variable "env" {
  type = string
}

variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "billing_account_id" {
  type = string
}

variable "org_id" {
  type    = string
  default = null
}

variable "folder_id" {
  type    = string
  default = null
}

variable "services" {
  type = list(string)
}

variable "state_bucket_region" {
  type = string
}

resource "google_project" "p" {
  project_id = var.project_id
  name       = var.project_name

  billing_account = var.billing_account_id

  # Use either org_id or folder_id
  org_id    = var.org_id
  folder_id = var.folder_id
}

resource "google_project_service" "svc" {
  for_each = toset(var.services)

  project = google_project.p.project_id
  service = each.value

  disable_on_destroy = false
}

resource "google_storage_bucket" "tf_state" {
  # IMPORTANT: bucket lives in the new project
  project = google_project.p.project_id

  name     = "${var.project_id}-tfstate"
  location = var.state_bucket_region

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  depends_on = [google_project_service.svc]
}

output "project_id" {
  value = google_project.p.project_id
}

output "project_number" {
  value = google_project.p.number
}

output "tf_state_bucket" {
  value = google_storage_bucket.tf_state.name
}