# FinOps Label Compliance Runbook

## Detect unlabeled spend

bq query --use_legacy_sql=false '
SELECT
project.id,
SUM(cost) cost
FROM `PROJECT.DATASET.TABLE`
WHERE labels IS NULL
GROUP BY project.id
'