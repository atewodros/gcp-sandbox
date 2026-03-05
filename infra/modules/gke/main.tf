variable "project_id" {
  type = string
}

variable "region" {
  type        = string
  description = "Region (used for networking + ancillary regional resources)"
}

variable "zone" {
  type        = string
  description = "Single zone for a zonal GKE cluster (e.g., us-east1-b)"
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

variable "num_nodes" {
  type        = number
  description = "Number of nodes in the default node pool"
  default     = 1
}

variable "labels" {
  type = map(string)
}
resource "google_container_cluster" "cluster" {
  project             = var.project_id
  name                = "${var.env}-gke"
  location            = var.zone
  resource_labels     = var.labels
  deletion_protection = false

  network    = var.network
  subnetwork = var.subnetwork

  # IMPORTANT:
  # Prevent GKE from creating the default node pool (which can trigger quota issues).
  remove_default_node_pool = true
  initial_node_count       = var.num_nodes
}

resource "google_container_node_pool" "default" {
  project  = var.project_id
  name     = "default-pool"
  location = var.zone
  cluster  = google_container_cluster.cluster.name

  node_count = var.num_nodes

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-standard"
    disk_size_gb = 30

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "cluster_location" {
  value = google_container_cluster.cluster.location
}
