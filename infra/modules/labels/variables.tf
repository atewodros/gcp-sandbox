variable "team" {
  description = "Owning ML team used for cost attribution and operational ownership."
  type        = string

  validation {
    condition     = contains(["trust-safety", "recommendations"], var.team)
    error_message = "team must be one of: trust-safety, recommendations."
  }
}

variable "model" {
  description = "Model identifier for cost tracking (controlled enum; extendable)."
  type        = string

  validation {
    condition = contains([
      "wasp",
      "bumble-dna",
      "shared",
      "platform",
    ], var.model)
    error_message = "model must be one of: wasp, bumble-dna, shared, platform."
  }
}

variable "env" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "managed_by" {
  description = "Ownership label indicating the managing platform/team."
  type        = string
  default     = "mlops-platform"

  validation {
    condition     = var.managed_by == "mlops-platform"
    error_message = "managed_by must be exactly: mlops-platform."
  }
}

variable "additional_labels" {
  description = "Optional additional labels to merge with the mandatory taxonomy."
  type        = map(string)
  default     = {}

  validation {
    condition = length(setintersection(
      toset(keys(var.additional_labels)),
      toset(["team", "model", "env", "managed-by"])
    )) == 0
    error_message = "additional_labels must not redefine mandatory keys."
  }
}

variable "enforce_lowercase_values" {
  description = "If true, validates that mandatory label values are lowercase."
  type        = bool
  default     = true
}
