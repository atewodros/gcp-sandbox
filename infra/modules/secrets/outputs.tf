output "secret_id" {
  value = google_secret_manager_secret.snowflake_connection.secret_id
}

output "secret_resource_name" {
  value = google_secret_manager_secret.snowflake_connection.name
}
