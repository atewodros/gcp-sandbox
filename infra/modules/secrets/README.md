# Terraform GCP Snowflake JSON Secret Module

This Terraform module creates a **single JSON Snowflake connection secret** in
Google Secret Manager and grants access to a **Vertex AI training service account**.

## Secret structure

Example JSON payload stored as a secret version:

{
  "host": "myaccount.snowflakecomputing.com",
  "user": "svc_payments",
  "password": "super-secret-password",
  "warehouse": "COMPUTE_WH",
  "database": "ANALYTICS",
  "schema": "PUBLIC"
}

Terraform creates only the secret container. Upload the secret payload after apply.
