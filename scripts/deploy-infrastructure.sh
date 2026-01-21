#! /bin/bash

set -e

# Get the directory of the script and the project root
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

echo "--- Deploying MuchToDo infrastructure ---"
# Deploy infrastructure using Terraform
echo "Deploying infrastructure with Terraform..."
cd "$PROJECT_ROOT/terraform"
terraform init
terraform apply -auto-approve

echo "--- Infrastructure deployed successfully 🚀 ---"