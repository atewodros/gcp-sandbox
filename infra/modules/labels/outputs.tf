output "labels" {
  description = "Merged labels map including mandatory taxonomy labels and any additional_labels."
  value       = local.merged_labels
}

output "mandatory_labels" {
  description = "Mandatory taxonomy labels only."
  value       = local.mandatory_labels
}
