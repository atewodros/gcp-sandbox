locals {
  cidr = var.env == "prod" ? "10.30.0.0/24" : (var.env == "stag" ? "10.20.0.0/24" : "10.10.0.0/24")
}

module "labels" {
  source = "../../modules/labels"

  project = "gcp-sandbox"
  env     = var.env
  owner   = "atewodros"
}

module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  region     = var.region
  env        = var.env
  cidr       = local.cidr
}

module "gke" {
  source     = "../../modules/gke"
  project_id = var.project_id
  zone       = var.zone
  region     = var.region
  env        = var.env
  network    = module.network.network_self_link
  subnetwork = module.network.subnet_self_link

  labels = module.labels.labels
}

module "ar" {
  source     = "../../modules/artifact_registry"
  project_id = var.project_id
  region     = var.region
  env        = var.env

  labels = module.labels.labels
}

module "cloud_run" {
  source       = "../../modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  env          = var.env
  service_name = "helloWorld"
  image        = var.cloud_run_image
  public       = true

  labels = module.labels.labels
}
