# Label Audit Automation Runbook

## Architecture

Cloud Scheduler
→ Cloud Function
→ BigQuery Label Audit
→ Slack / Email Alert

## Example compliance query

bq query --use_legacy_sql=false '
SELECT
l.key,
COUNT(*)
FROM `PROJECT.DATASET.TABLE`,
UNNEST(labels) l
GROUP BY l.key
'