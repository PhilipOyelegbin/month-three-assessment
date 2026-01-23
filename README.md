# Month 3 Assessment - Full-Stack CI/CD Pipeline Implementation

Created a comprehensive CI/CD pipeline that automates the entire deployment process from code commit to production, including proper monitoring and security practices.

---

## Setup Instructions

1. Clone the repo and change directory using the command below

   ```bash
   git clone https://github.com/PhilipOyelegbin/month-three-assessment.git

   cd month-three-assessment
   ```

2. Update the file permission of the files in **scripts** folder and create keygen for the infrastucture

   ```bash
   chmod 740 scripts/*

   ssh-keygen -t ed25519 -f ./terraform/id_rsa -N ""
   ```

3. Run the infrastructure deployment script

   ```bash
   ./scripts/deploy-infrastructure.sh
   ```

   ![snapshot](./evidence/infra.png)

4. Update the environmental variables appropriately
   - frontend/.env
   - backend/MuchToDo/.env

5. Update the script file below with appropriate variable details from the infrastructure output
   - scripts/deploy-backend.sh
   - scripts/deploy-frontend.sh
   - scripts/health-check.sh
   - scripts/rollback.sh

6. Run the deploy script to deploy the application

   ```bash
   ./scripts/deploy-backend.sh
   ./scripts/deploy-frontend.sh
   ```

   ![snapshot](./evidence/backend.png)
   ![snapshot](./evidence/frontend.png)

7. Run the healh check script to confirm the services are healthy

   ```bash
   ./scripts/health-check.sh
   ```

   ![snapshot](./evidence/health.png)

8. The application should be accessible via the cloudfront dns url and load balancer url.

   ![snapshot](./evidence/preview1.png)
   ![snapshot](./evidence/preview2.png)

9. Destroy the infrastructure by running the rollback script

   ```bash
   ./scripts/rollback.sh
   ```

   ![snapshot](./evidence/rollback.png)

---

## CI/CD Implementation

The CI-CD pipeline runs based on the updated folder, if the **terraform** folder is updated the `infrastructure-deploy.yml` pipeline is triggered, likewise when the **backend** folder is updated the `backend-ci-cd.yml` pipeline is triggered, also the `frontend-ci-cd.yml` pipeline is triggered on **frontend** folder update and pushed to github.

**Infrastructure Pipeline**

- Plan: This phase is triggered when an update is made to the **terraform** folder and pushed to the **stagging** branch
- Apply: This phase is triggered when a PR is merged to the **main** branch from the **stagging** branch.
- Cleanup: This phase is triggered when a PR is merged to the **clean** branch.

**Backend Pipeline**

- Build: This phase is triggered when an update is made to the **backend** folder and pushed to the **stagging** branch
- Deploy: This phase is triggered when a PR is merged to the **main** branch from the **stagging** branch.
- Cleanup: This phase is triggered when a PR is merged to the **clean** branch.

**Frontend Pipeline**

- Build: This phase is triggered when an update is made to the **frontend** folder and pushed to the **stagging** branch
- Deploy: This phase is triggered when a PR is merged to the **main** branch from the **stagging** branch.

---

## Task Completed

- [x] Created Auto Scaling Group for backend EC2 instances
- [x] Created Application Load Balancer with target group
- [x] Created S3 bucket for frontend hosting with static website configuration
- [x] Created CloudFront distribution for global content delivery
- [x] Created ElastiCache Redis cluster for caching
- [x] Created CloudWatch Log Groups for application logging
- [x] Created IAM roles and policies for EC2 instances to access CloudWatch
- [x] Created Security Groups for all components
- [x] Scripts created and functional
- [x] Pipeline created and functional

---
