# Implementation Plan --- Apply Label Taxonomy to ML Projects

## Objective

Apply the agreed mandatory GCP label taxonomy to all ML projects and
validate that labels flow through to the Billing export for accurate
cost attribution.

------------------------------------------------------------------------

## Scope

Projects included:

-   6 ML projects
-   1 ml-sandbox project

All projects must include the following required labels:

  Key          Allowed Values
  ------------ ----------------------------------------
  team         trust-safety / recommendations
  model        wasp / bumble-dna / approved allowlist
  env          dev / staging / prod
  managed-by   mlops-platform

------------------------------------------------------------------------

# 1. Apply Labels via Terraform

Labels must be applied at the project level.

Example Terraform module usage of gcp_ml_lables:

``` hcl
Update your project resource:

resource "google_project" "ml_project" {
  name            = "ml-wasp-prod"
  project_id      = "ml-wasp-prod"
  org_id          = var.org_id
  billing_account = var.billing_account
  labels = module.gcp_ml_lables.labels
  
}

```

Apply changes:

``` bash
terraform init
terraform plan
terraform apply
```

------------------------------------------------------------------------

# 2. Validate Project Labels

Verify a single project:

``` bash
gcloud projects describe PROJECT_ID --format="json(labels)"
```

Validate all ML projects:

``` bash
gcloud projects list --filter="labels.managed-by=mlops-platform"
```

All 7 projects must appear in the output.

------------------------------------------------------------------------

# 3. Confirm Billing Export Is Enabled

Ensure Billing export to BigQuery is configured.

Check billing account:

``` bash
gcloud beta billing accounts describe BILLING_ACCOUNT_ID
```

Confirm BigQuery dataset exists:

billing_export.gcp_billing_export_v1_XXXXXX

------------------------------------------------------------------------

# 4. Validate Labels in Billing Dataset

Check available label keys:

``` sql
SELECT DISTINCT key
FROM `billing_export.gcp_billing_export_v1_*`,
UNNEST(project.labels)
ORDER BY key;
```

Expected keys:

-   team
-   model
-   env
-   managed-by

------------------------------------------------------------------------

# 5. Sample Cost Query by Team

``` sql
SELECT
  project_label.value AS team,
  SUM(cost) AS total_cost
FROM
  `billing_export.gcp_billing_export_v1_*`,
  UNNEST(project.labels) AS project_label
WHERE
  project_label.key = "team"
  AND usage_start_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY team
ORDER BY total_cost DESC;
```

------------------------------------------------------------------------

# 6. Acceptance Criteria Checklist

-   All 7 ML projects have required labels applied.
-   Labels are visible in BigQuery Billing export dataset.
-   Cost query by team returns expected results.
-   Labels are enforced via Terraform for future resources.

------------------------------------------------------------------------

# Operational Notes

-   Billing export visibility may take 24--48 hours.
-   Labels are not retroactive for historical billing data.
-   Terraform enforcement prevents label drift.
