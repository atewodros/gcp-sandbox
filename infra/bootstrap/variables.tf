variable "org_id" {
  description = "GCP Organization ID (required if not using folder_id)"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "GCP Folder ID (optional alternative to org_id)"
  type        = string
  default     = null
}

variable "billing_account_id" {
  description = "Billing account ID like 000000-000000-000000"
  type        = string
}

variable "project_prefix" {
  description = "Prefix for project IDs"
  type        = string
  default     = "atewodros"
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "github_owner" {
  type = string
}
variable "github_repo" {
  type = string
}
