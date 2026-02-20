variable "project_id" {
  type = string
}
variable "env" {
  type = string
}
variable "github_owner" {
  type = string
}
variable "github_repo" {
  type = string
}

data "google_project" "p" { project_id = var.project_id }

resource "google_iam_workload_identity_pool" "pool" {
  project                   = var.project_id
  workload_identity_pool_id  = "github-${var.env}"
  display_name               = "GitHub OIDC (${var.env})"
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Provider"

  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "attribute.repository == '${var.github_owner}/${var.github_repo}'"
}

resource "google_service_account" "tf_deployer" {
  project      = var.project_id
  account_id   = "tf-deployer-${var.env}"
  display_name = "Terraform Deployer (${var.env})"
}

resource "google_service_account_iam_member" "wif" {
  service_account_id = google_service_account.tf_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/projects/${data.google_project.p.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

output "workload_identity_provider" {
  value = "projects/${data.google_project.p.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id}"
}

output "tf_deployer_email" { value = google_service_account.tf_deployer.email }
