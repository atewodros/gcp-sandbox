#!/usr/bin/env bash
set -euo pipefail

PROJECT=$1
SECRET=$2
FILE=$3

gcloud secrets versions add "$SECRET"   --project "$PROJECT"   --data-file="$FILE"
