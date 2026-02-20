variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "env" {
  type = string
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.env}-docker"
  format        = "DOCKER"
  description   = "Docker images for ${var.env}"
}

output "repo_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}
