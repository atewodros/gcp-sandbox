output "cloud_run_url" {
  value = module.cloud_run.url
}

output "artifact_registry_repo" {
  value = module.ar.repo_url
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "gke_location" {
  value = module.gke.cluster_location
}

