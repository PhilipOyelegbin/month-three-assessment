#! /bin/bash

set -e

# Variables
BUCKET_NAME="muchtodo-bucket"
FRONTEND_DIR="frontend/dist"

echo "--- Starting deployment of MuchToDo frontend ---"
# Deploy frontend application to s3 bucket
echo "Deploying frontend application..."
npm install --prefix frontend/
npm run build --prefix frontend/
aws s3 sync $FRONTEND_DIR s3://$BUCKET_NAME --delete
echo "Frontend application deployed to S3 bucket: $BUCKET_NAME."

echo "--- MuchToDo frontend deployment completed 🎉 ---"