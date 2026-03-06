variable "team" {
  description = "Owning team for the resource."
  type        = string

  validation {
    condition     = contains(["trust-safety", "recommendations"], var.team)
    error_message = "team must be one of: trust-safety, recommendations."
  }
}

variable "model" {
  description = "Model identifier (curated allowlist)."
  type        = string

  validation {
    condition     = length(var.model) > 0
    error_message = "model must be a non-empty string."
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
  description = "Enforced constant to indicate platform ownership."
  type        = string
  default     = "mlops-platform"

  validation {
    condition     = var.managed_by == "mlops-platform"
    error_message = "managed_by must be exactly: mlops-platform."
  }
}

variable "allowed_models" {
  description = "Allowlist of approved model label values. Extend via PR."
  type        = set(string)
  default     = ["wasp", "bumble-dna"]
}

variable "extra_labels" {
  description = "Optional additional labels (mandatory labels always win)."
  type        = map(string)
  default     = {}
}
