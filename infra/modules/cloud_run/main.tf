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

resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = "${var.env}-run-runtime"
  display_name = "Cloud Run Runtime (${var.env})"
}

resource "google_cloud_run_v2_service" "svc" {
  project  = var.project_id
  location = var.region
  name     = "${var.env}-${var.service_name}"

  template {
    service_account = google_service_account.runtime.email
    containers { image = var.image }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count    = var.public ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.svc.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" { value = google_cloud_run_v2_service.svc.uri }
