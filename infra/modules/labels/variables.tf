variable "project" {
  type        = string
  description = "Logical project label (NOT the GCP project_id). Example: gcp-sandbox"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,62}$", var.project))
    error_message = "project must match ^[a-z][a-z0-9_-]{0,62}$ (lowercase, 63 chars max)."
  }
}

variable "env" {
  type        = string
  description = "Environment label. Allowed: sandbox, stag, prod."

  validation {
    condition     = contains(["sandbox", "stag", "prod"], var.env)
    error_message = "env must be one of: sandbox, stag, prod."
  }
}

variable "owner" {
  type        = string
  description = "Owner/team responsible for the resources (lowercase recommended)."

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,62}$", var.owner))
    error_message = "owner must match ^[a-z][a-z0-9_-]{0,62}$ (lowercase, 63 chars max)."
  }
}

variable "team" {
  type        = string
  description = "Engineering team (lowercase)."
  default     = "platform"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,62}$", var.team))
    error_message = "team must match ^[a-z][a-z0-9_-]{0,62}$ (lowercase, 63 chars max)."
  }
}

variable "service" {
  type        = string
  description = "Service/application name (lowercase)."
  default     = "platform"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,62}$", var.service))
    error_message = "service must match ^[a-z][a-z0-9_-]{0,62}$ (lowercase, 63 chars max)."
  }
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing/chargeback (lowercase)."
  default     = "engineering"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,62}$", var.cost_center))
    error_message = "cost_center must match ^[a-z][a-z0-9_-]{0,62}$ (lowercase, 63 chars max)."
  }
}

variable "compliance" {
  type        = string
  description = "Compliance classification (expand as needed)."
  default     = "none"

  validation {
    condition     = contains(["none", "pci", "hipaa", "sox", "gdpr"], var.compliance)
    error_message = "compliance must be one of: none, pci, hipaa, sox, gdpr."
  }
}

variable "data_classification" {
  type        = string
  description = "Data classification level."
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "restricted"], var.data_classification)
    error_message = "data_classification must be one of: public, internal, restricted."
  }
}

variable "managed_by" {
  type        = string
  description = "IaC tool managing the resources."
  default     = "terraform"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,62}$", var.managed_by))
    error_message = "managed_by must match ^[a-z][a-z0-9_-]{0,62}$ (lowercase, 63 chars max)."
  }
}

variable "extra_labels" {
  type        = map(string)
  description = "Additional labels merged into the base set."
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.extra_labels :
      can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) &&
      can(regex("^[a-z0-9_-]{0,63}$", v))
    ])
    error_message = "extra_labels keys must match ^[a-z][a-z0-9_-]{0,62}$ and values must match ^[a-z0-9_-]{0,63}$."
  }
}
