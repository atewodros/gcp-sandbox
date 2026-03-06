variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "vertex_training_service_account_email" {
  type = string
}
