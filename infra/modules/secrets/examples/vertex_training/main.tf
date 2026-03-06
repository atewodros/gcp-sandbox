provider "google" {
  project = var.project_id
  region  = var.region
}

module "snowflake_secret" {
  source = "../../modules/snowflake_json_secret"

  project_id = var.project_id
  region     = var.region

  secret_prefix = "ml-prod-snowflake"

  vertex_training_service_account_email = var.vertex_training_service_account_email
}
