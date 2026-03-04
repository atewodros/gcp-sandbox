variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "image" {
  type = string
}

variable "public" {
  type    = bool
  default = false
}
variable "labels" {
  type = map(string)
}
# Ensure required APIs are enabled in the target project.
# This avoids failures like:
# "Artifact Registry API has not been used... or it is disabled"
locals {
  required_services = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

resource "google_project_service" "required" {
  for_each = toset(local.required_services)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = "${var.env}-run-runtime"
  display_name = "Cloud Run Runtime (${var.env})"

  depends_on = [google_project_service.required]
}

resource "google_cloud_run_v2_service" "svc" {
  project  = var.project_id
  location = var.region
  name     = "${var.env}-${var.service_name}"
  labels   = var.labels
  template {
    service_account = google_service_account.runtime.email

    containers {
      image = var.image
    }
  }

  # Force ordering so API enablement has completed before service creation.
  depends_on = [google_project_service.required]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count    = var.public ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.svc.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = google_cloud_run_v2_service.svc.uri
}