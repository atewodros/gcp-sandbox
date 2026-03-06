# GCP Terraform Labels Analysis Report

## Executive Summary

This analysis reveals inconsistent label implementation across Terraform modules. The `apis` module lacks label support entirely due to GCP resource limitations, while other modules implement varying label patterns. A standardized labels module would improve consistency, but the `apis` module cannot directly apply labels since `google_project_service` resources don't support them. Current label usage shows good adherence to GCP constraints but lacks comprehensive coverage.

## Findings Table by File/Resource

| File/Resource | Labels Supported | Current Implementation | Issues |
|---------------|------------------|------------------------|---------|
| `modules/apis/main.tf` | ❌ No | N/A - `google_project_service` doesn't support labels | Cannot add labels due to GCP API limitation |
| `modules/vertex-endpoint/main.tf` | ✅ Yes | `labels = local.merged_labels` on `google_vertex_ai_endpoint` | Good implementation with defaults + custom merge |
| `modules/workbench-notebook/main.tf` | ✅ Yes | `labels = local.merged_labels` on `google_workbench_instance` | Good implementation, but SA/IAM resources unlabeled |
| `modules/gcs-buckets/main.tf` | ✅ Yes | `labels = merge(var.default_labels, each.value.labels, {...})` on `google_storage_bucket` | Good implementation with per-bucket overrides |
| `modules/artifact-registry/main.tf` | ✅ Yes | `labels = merge({environment, managed_by}, each.value.labels)` on `google_artifact_registry_repository` | Good implementation |
| `modules/cloudbuild-github-connection/main.tf` | ❓ Unknown | No labels applied | Need to verify if `google_cloudbuildv2_*` resources support labels |
| `modules/project-iam-group-binding/main.tf` | ❌ No | IAM resources don't support labels | Expected - GCP limitation |
| `environments/staging/api.tf` | ❌ No | Module called without labels | Consistent with module capability |
| `environments/staging/endpoints.tf` | ✅ Yes | `labels = each.value.labels` passed to vertex-endpoint | Good - labels flow from variables |
| `environments/staging/notebook.tf` | ✅ Yes | `labels = each.value.labels` passed to workbench-notebook | Good - labels flow from variables |
| `environments/tools/buckets.tf` | ✅ Yes | `default_labels = {purpose = "cicd"}` passed to gcs-buckets | Good - environment-specific defaults |
| `environments/prod/api.tf` | ❌ No | Module called without labels | Consistent with module capability |

## Recommended GCP Label Design

### Standardized Labels Module Structure

```hcl
# modules/labels/main.tf
locals {
  # Base labels applied to all resources
  base_labels = {
    environment = var.env
    team        = var.team
    managed_by  = "terraform"
  }

  # Service-specific labels
  service_labels = {
    service = var.service
  }

  # Merge all labels
  all_labels = merge(
    local.base_labels,
    local.service_labels,
    var.additional_labels
  )
}

# modules/labels/outputs.tf
output "labels" {
  description = "Standardized labels map"
  value       = local.all_labels
}

output "base_labels" {
  description = "Base labels only"
  value       = local.base_labels
}
```

### Label Key/Value Constraints Compliance

All current labels comply with GCP constraints:
- ✅ Keys: lowercase, start with letter, ≤63 chars, alphanumeric + hyphens
- ✅ Values: ≤63 chars, alphanumeric + hyphens + underscores
- No violations found in current implementation

## Terraform Refactor Examples

### 1. Add Labels Module to APIs Module (Documentation Only)

```hcl
# modules/apis/main.tf - ADD THIS (for consistency, even though not applied)
locals {
  # Labels for documentation/tracking (cannot be applied to google_project_service)
  labels = var.labels
}

# modules/apis/variables.tf - ADD THIS
variable "labels" {
  description = "Labels for tracking (not applied to resources due to GCP limitations)"
  type        = map(string)
  default     = {}
}

# modules/apis/outputs.tf - ADD THIS
output "labels" {
  description = "Labels passed to module (for reference only)"
  value       = local.labels
}
```

### 2. Standardize Vertex-Endpoint Labels Pattern

```hcl
# modules/vertex-endpoint/main.tf - CURRENT IS GOOD
locals {
  default_labels = {
    environment = var.environment
    model       = var.model_name
    team        = var.team
    managed_by  = "terraform"
  }
  merged_labels = merge(local.default_labels, var.labels)
}
```

### 3. Update GCS Buckets for Consistency

```hcl
# modules/gcs-buckets/main.tf - ADD STANDARD DEFAULTS
labels = merge(
  {
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "storage"
  },
  var.default_labels,
  each.value.labels
)
```

### 4. Environment Usage with Labels Module

```hcl
# environments/staging/api.tf - ADD LABELS MODULE
module "labels" {
  source = "../../modules/labels"

  team  = "recommendations"
  model = "wasp"
  env   = "staging"

  additional_labels = {
    service = "recs-inference"
  }
}

module "apis" {
  source = "../../modules/apis"

  project_id = var.project_id
  additional_apis = [
    "aiplatform.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "notebooks.googleapis.com",
  ]

  # Labels for tracking (not applied to resources)
  labels = module.labels.labels
}
```

## Phased Patch Plan

### Phase 1: Core Infrastructure (Week 1)
1. Create `modules/labels/` with standardized label logic
2. Update `modules/vertex-endpoint/` to use labels module pattern
3. Update `modules/workbench-notebook/` to use labels module pattern
4. Update `modules/gcs-buckets/` to use consistent defaults

### Phase 2: Environment Updates (Week 2)
1. Update all environment `*.tf` files to use labels module
2. Add labels to `environments/staging/endpoints.tf` and `environments/staging/notebook.tf`
3. Add labels to `environments/tools/buckets.tf`
4. Update `environments/prod/endpoints.tf` (currently commented)

### Phase 3: Documentation & Validation (Week 3)
1. Add labels documentation to all module READMEs
2. Add label validation in CI/CD pipelines
3. Update `modules/apis/` with labels variable (for consistency)
4. Create label governance documentation

### Phase 4: Monitoring & Compliance (Week 4)
1. Add label compliance checks to validation workflows
2. Implement label drift detection
3. Add labels to any newly discovered resources
4. Establish label usage reporting

## Key Insights

- **GCP Resource Limitations**: `google_project_service` cannot have labels - this is a platform limitation
- **IAM Resources**: Service accounts and IAM bindings cannot be labeled - expected GCP behavior
- **Inconsistent Patterns**: Some modules use `default_labels + var.labels`, others use different merge strategies
- **Missing Coverage**: Cloud Build connections and repositories may support labels but aren't using them
- **Environment Gaps**: Production environment has commented code that should include labels

The `apis` module cannot directly apply labels due to GCP API constraints, but should accept them for consistency and future extensibility. All other modules should adopt the standardized labels pattern shown in the vertex-endpoint module.