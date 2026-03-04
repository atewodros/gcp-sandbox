locals {
  base_labels = {
    project     = var.project
    environment = var.env
    owner       = var.owner
    managed_by  = var.managed_by
  }

  labels = merge(local.base_labels, var.extra_labels)
}
