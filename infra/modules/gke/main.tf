variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "env" {
  type = string
}
variable "network" {
  type = string
}
variable "subnetwork" {
  type = string
}

resource "google_container_cluster" "cluster" {
  project  = var.project_id
  name     = "${var.env}-gke"
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel { channel = "REGULAR" }
}

resource "google_container_node_pool" "primary" {
  project    = var.project_id
  name       = "${var.env}-primary"
  location   = var.region
  cluster    = google_container_cluster.cluster.name
  node_count = var.env == "prod" ? 2 : 1

  node_config {
    machine_type = var.env == "prod" ? "e2-standard-4" : "e2-standard-2"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = { env = var.env, managed = "terraform" }
  }
}

output "cluster_name" { value = google_container_cluster.cluster.name }
output "location" { value = var.region }
