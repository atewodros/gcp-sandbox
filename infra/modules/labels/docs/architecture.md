# Architecture

This platform provisions Google Cloud infrastructure using Terraform and deploys workloads using GitHub Actions.

## High Level Architecture

GitHub Actions → Workload Identity Federation → Terraform → Google Cloud

Components:

- VPC Network
- Subnet
- GKE Cluster
- Node Pools
- Artifact Registry
- Cloud Run

Terraform state is stored in a GCS bucket.