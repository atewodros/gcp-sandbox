variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "env" {
  type = string
}

variable "cloud_run_image" {
  type    = string
  # Updated by CI/CD deploy; placeholder for initial apply
  default = "us-east1-docker.pkg.dev/placeholder/placeholder/hello:latest"
}
