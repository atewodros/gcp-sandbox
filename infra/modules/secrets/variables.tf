variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "secret_prefix" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "kms_key_name" {
  type    = string
  default = null
}

variable "vertex_training_service_account_email" {
  type = string
}
