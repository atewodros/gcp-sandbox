# Terraform Troubleshooting

## terraform init errors

Check providers and backend configuration.

## terraform validate failures

Run:

terraform fmt -recursive
terraform validate

## State conflicts

Check resources:

terraform state list
terraform state show RESOURCE_NAME