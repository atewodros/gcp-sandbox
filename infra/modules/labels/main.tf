locals {
  mandatory_labels = {
    team       = var.team
    model      = var.model
    env        = var.env
    managed-by = var.managed_by
  }

  merged_labels = merge(local.mandatory_labels, var.additional_labels)
}

resource "terraform_data" "label_validation" {
  input = local.merged_labels

  lifecycle {
    precondition {
      condition = (
        var.enforce_lowercase_values == false
        ||
        (
          lower(var.team) == var.team
          && lower(var.model) == var.model
          && lower(var.env) == var.env
          && lower(var.managed_by) == var.managed_by
        )
      )
      error_message = "Mandatory label values must be lowercase when enforce_lowercase_values=true."
    }
  }
}
