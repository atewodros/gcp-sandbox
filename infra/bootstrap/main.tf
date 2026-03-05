locals {
  envs = {
    sandbox = {
      project_id   = "${var.project_prefix}-sandbox"
      project_name = "${var.project_prefix}-sandbox"
    }
    stag = {
      project_id   = "${var.project_prefix}-stag"
      project_name = "${var.project_prefix}-stag"
    }
    prod = {
      project_id   = "${var.project_prefix}-prod"
      project_name = "${var.project_prefix}-prod"
    }
  }

  # Enable required APIs in ALL projects
  services = [
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",

    "compute.googleapis.com",
    "container.googleapis.com",        # GKE
    "run.googleapis.com",              # Cloud Run
    "artifactregistry.googleapis.com", # Artifact Registry  ✅ FIX
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

module "projects" {
  for_each = local.envs
  source   = "../modules/project"

  env                = each.key
  project_id         = each.value.project_id
  project_name       = each.value.project_name
  billing_account_id = var.billing_account_id
  org_id             = var.org_id
  folder_id          = var.folder_id
  services           = local.services

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