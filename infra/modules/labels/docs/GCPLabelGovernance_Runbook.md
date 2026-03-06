# GCP Label Governance Runbook

## Validate project labels

gcloud projects describe PROJECT_ID --format="json(labels)"

## Validate GKE cluster labels

gcloud container clusters describe CLUSTER_NAME --region REGION

## Validate compute labels

gcloud compute instances list --format="table(name,labels)"