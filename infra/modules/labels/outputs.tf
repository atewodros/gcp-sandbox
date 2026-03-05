output "labels" {
  description = "Merged label map (GCP label-compliant)."
  value       = local.labels
}

output "required_keys" {
  description = "Recommended enterprise label keys."
  value = [
    "environment",
    "project",
    "owner",
    "team",
    "service",
    "cost_center",
    "compliance",
    "data_classification",
    "managed_by",
  ]
}
