locals {
  labels = merge(
    {
      managed_by = "terraform"
      system     = "snowflake"
    },
    var.labels
  )
}

resource "google_secret_manager_secret" "snowflake_connection" {

  project   = var.project_id
  secret_id = "${var.secret_prefix}-connection"

  labels = local.labels

  replication {
    user_managed {
      replicas {
        location = var.region

        dynamic "customer_managed_encryption" {
          for_each = var.kms_key_name != null ? [1] : []
          content {
            kms_key_name = var.kms_key_name
          }
        }
      }
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "vertex_training_accessor" {

  project   = var.project_id
  secret_id = google_secret_manager_secret.snowflake_connection.secret_id

  role = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${var.vertex_training_service_account_email}"
  ]
}
