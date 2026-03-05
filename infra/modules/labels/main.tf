locals {
  reserved_keys = toset(["team", "model", "env", "managed-by", "managed_by"])

  mandatory_labels = {
    team       = var.team
    model      = var.model
    env        = var.env
    managed-by = var.managed_by
  }

  extra_label_keys        = toset(keys(var.extra_labels))
  reserved_keys_in_extras = setintersection(local.extra_label_keys, local.reserved_keys)
  extras_do_not_override  = length(local.reserved_keys_in_extras) == 0

  model_allowed = contains(var.allowed_models, var.model)

  labels = merge(var.extra_labels, local.mandatory_labels)
}

resource "terraform_data" "label_guard" {
  input = local.labels

  lifecycle {
    precondition {
      condition     = local.model_allowed
      error_message = "model must be one of allowed_models."
    }

    precondition {
      condition     = local.extras_do_not_override
      error_message = "extra_labels must not include reserved keys."
    }
  }
}
