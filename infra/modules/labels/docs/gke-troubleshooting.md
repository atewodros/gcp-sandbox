# GKE Troubleshooting

List clusters:

gcloud container clusters list

Describe cluster:

gcloud container clusters describe CLUSTER_NAME --region REGION

Check node pools:

gcloud container node-pools list --cluster CLUSTER_NAME --region REGION