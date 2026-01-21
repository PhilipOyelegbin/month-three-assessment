#! /bin/bash

set -e

# Variables
S3_BUCKET_NAME="muchtodo-bucket"
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

echo "--- Starting Rollback Process for MuchToDo ---"
# Frontend rollback
echo "Remove MuchToDo frontend deployed files from s3 bucket..."
aws s3 rm s3://$S3_BUCKET_NAME --recursive
echo "Removed MuchToDo frontend deployed files from s3 bucket."

# Infrastructure rollback
echo "Rolling back infrastructure by destroying Terraform-managed resources..."
cd "$PROJECT_ROOT/terraform"
terraform destroy -auto-approve
echo "Destroyed Terraform-managed infrastructure."

echo "--- Rollback completed 🎉 ---"