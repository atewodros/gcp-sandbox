terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  # Uses your local gcloud ADC for bootstrap
}

locals {
  envs = {
    sandbox = { name = "sandbox" }
    stag    = { name = "stag" }
    prod    = { name = "prod" }
  }

  required_services = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]

  # Baseline Terraform roles (practical). Tighten further later if desired.
  tf_roles = [
    "roles/serviceusage.serviceUsageAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/compute.networkAdmin",
    "roles/container.admin",
    "roles/run.admin",
    "roles/artifactregistry.admin",
  ]
}

module "projects" {
  for_each = local.envs
  source   = "../modules/project"

  env                 = each.key
  project_id          = "${var.project_prefix}-${each.key}"
  project_name        = "${var.project_prefix}-${each.key}"
  billing_account_id  = var.billing_account_id
  org_id              = var.org_id
  folder_id           = var.folder_id
  services            = local.required_services
  state_bucket_region = var.region
}

module "wif" {
  for_each = local.envs
  source   = "../modules/github_wif"

  project_id   = module.projects[each.key].project_id
  env          = each.key
  github_owner = var.github_owner
  github_repo  = var.github_repo
}

module "tf_iam" {
  for_each = local.envs
  source   = "../modules/iam"

  project_id = module.projects[each.key].project_id
  member     = "serviceAccount:${module.wif[each.key].tf_deployer_email}"
  roles      = local.tf_roles
}

# State bucket access: bucket-level, not project-wide.
resource "google_storage_bucket_iam_member" "state_bucket_object_admin" {
  for_each = local.envs
  bucket   = module.projects[each.key].tf_state_bucket
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${module.wif[each.key].tf_deployer_email}"
}
