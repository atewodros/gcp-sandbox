# ValidateLabelsInBillingDataset_Runbook.md

## Purpose
Validate Google Cloud resource labels in the Cloud Billing BigQuery export dataset using gcloud and bq CLI.

## Prerequisites
- Google Cloud CLI installed
- BigQuery CLI (bq) installed
- Billing export to BigQuery enabled

Check installations:

gcloud --version
bq version

## Step 1 — Set the correct project
gcloud config set project BILLING_EXPORT_PROJECT
gcloud config get-value project

## Step 2 — List BigQuery datasets
bq ls

## Step 3 — List billing tables
bq ls BILLING_DATASET

Common tables:
- gcp_billing_export_v1
- gcp_billing_export_resource_v1

## Step 4 — Inspect schema
bq show --schema --format=prettyjson PROJECT_ID:DATASET.TABLE

Look for the `labels` field.

## Step 5 — Validate labels exist
bq query --use_legacy_sql=false '
SELECT
  project.id AS project_id,
  service.description AS service,
  labels
FROM `PROJECT_ID.DATASET.TABLE`
WHERE labels IS NOT NULL
LIMIT 20
'

## Step 6 — Validate the environment label
bq query --use_legacy_sql=false '
SELECT
  project.id AS project_id,
  l.key,
  l.value,
  cost
FROM `PROJECT_ID.DATASET.TABLE`,
UNNEST(labels) AS l
WHERE l.key = "environment"
LIMIT 50
'

## Step 7 — Validate cost by environment
bq query --use_legacy_sql=false '
SELECT
  l.value AS environment,
  ROUND(SUM(cost),2) AS total_cost
FROM `PROJECT_ID.DATASET.TABLE`,
UNNEST(labels) AS l
WHERE l.key = "environment"
GROUP BY environment
ORDER BY total_cost DESC
'

## Step 8 — Detect unlabeled spend
bq query --use_legacy_sql=false '
SELECT
  project.id AS project_id,
  ROUND(SUM(cost),2) AS unlabeled_cost
FROM `PROJECT_ID.DATASET.TABLE`
WHERE NOT EXISTS (
  SELECT 1 FROM UNNEST(labels) AS l WHERE l.key="environment"
)
GROUP BY project_id
ORDER BY unlabeled_cost DESC
'

## Step 9 — Validate enterprise label set
Expected labels:
environment
owner
team
service
cost_center
managed_by

bq query --use_legacy_sql=false '
SELECT
  l.key,
  COUNT(*) AS usage_count,
  ROUND(SUM(cost),2) AS cost_total
FROM `PROJECT_ID.DATASET.TABLE`,
UNNEST(labels) AS l
WHERE l.key IN (
  "environment",
  "owner",
  "team",
  "service",
  "cost_center",
  "managed_by"
)
GROUP BY l.key
ORDER BY l.key
'

## Troubleshooting

### No labels returned
Possible causes:
- Resources created before labels were applied
- Billing export delay
- Incorrect dataset/table

### Permission denied
Required roles:
roles/bigquery.dataViewer
roles/bigquery.jobUser

## Best Practices
- Enforce labels with Terraform modules
- Run scheduled compliance queries
- Monitor label coverage regularly