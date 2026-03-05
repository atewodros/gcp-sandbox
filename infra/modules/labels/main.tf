locals {
  base_labels = {
    project             = var.project
    environment         = var.env
    owner               = var.owner
    team                = var.team
    service             = var.service
    cost_center         = var.cost_center
    compliance          = var.compliance
    data_classification = var.data_classification
    managed_by          = var.managed_by
  }

  # Merge caller-provided extra labels (overrides base keys if duplicated)
  labels = merge(local.base_labels, var.extra_labels)
}
