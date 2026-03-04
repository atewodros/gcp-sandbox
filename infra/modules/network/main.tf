variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "env" {
  type = string
}
variable "cidr" {
  type = string
}
variable "labels" {
  type = map(string)
}
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "${var.env}-vpc"
  auto_create_subnetworks = false
  labels                  = var.labels
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "${var.env}-subnet"
  region        = var.region
  ip_cidr_range = var.cidr
  network       = google_compute_network.vpc.id
}

output "network_self_link" { value = google_compute_network.vpc.self_link }
output "subnet_self_link" { value = google_compute_subnetwork.subnet.self_link }
