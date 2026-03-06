output "labels" {
  description = "Merged labels map to apply to all resources."
  value       = local.labels
}

output "mandatory_labels" {
  description = "Only the mandatory labels."
  value       = local.mandatory_labels
}
