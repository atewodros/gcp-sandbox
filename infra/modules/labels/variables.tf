variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment (sandbox, stag, prod)"
}

variable "owner" {
  type        = string
  description = "Owner or team"
}

variable "managed_by" {
  type    = string
  default = "terraform"
}

variable "extra_labels" {
  type    = map(string)
  default = {}
}
