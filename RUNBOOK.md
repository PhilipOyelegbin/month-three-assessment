# StartTech Runbook

This runbook provides operational guidance for managing and troubleshooting the StartTech infrastructure.

## 1. Deployment Procedures

### Deploying Infrastructure

1. Navigate to the `terraform/` directory in the `starttech` repo.
2. Setup the remote state by navigating to `backend/` in the terraform directory.
3. Initialize Terraform: `terraform init`.
4. Review changes: `terraform plan`.
5. Apply changes: `terraform apply`.
6. Return to the root `terraform/` directory.
7. Update the bucket name of the remote state in `main.tf` file.
8. Initialize Terraform: `terraform init`.
9. Review changes: `terraform plan`.
10. Apply changes: `terraform apply`.

### Manual Frontend Sync

If the GitHub Action fails, you can manually sync the build:

`aws s3 sync ./build s3://your-frontend-bucket-name --delete`.

## 2. Monitoring & Troubleshooting

### Accessing Logs

- **Application Logs**: Navigate to **CloudWatch Logs** and look for the `/aws/app/starttech-backend` log group.

- **Querying Logs**: Use **CloudWatch Logs Insights** with the queries provided in `log-insights-queries.txt` to filter for errors.

### Scaling Issues

- **Symptom**: High CPU utilization on backend instances.
- **Action**: Check the **Auto Scaling Group** activity tab in the AWS Console to ensure new instances are being provisioned according to the scaling policy.

## 3. Incident Response

### Clearing Cache

If the frontend is not showing recent updates, manually invalidate the CloudFront cache:

`aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"`.

### Rolling Back the Deployment

Clean up the deployemnt and infrastructure.

## 4. Security & Access

- **Secrets**: All API keys and MongoDB credentials must be stored in **GitHub Secrets**; never hardcode them in the repository.

- **IAM**: Ensure the `EC2Role` has the `CloudWatchAgentServerPolicy` attached to allow log streaming.

---
