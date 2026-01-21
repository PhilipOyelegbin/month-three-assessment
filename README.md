# Month 3 Assessment - Full-Stack CI/CD Pipeline Implementation

Created a comprehensive CI/CD pipeline that automates the entire deployment process from code commit to production, including proper monitoring and security practices.

---

## Setup Instructions

1. Clone the repo and change directory using the command below

   ```bash
   git clone https://github.com/PhilipOyelegbin/month-three-assessment.git

   cd month-three-assessment
   ```

2. Update the file permission of the files in **scripts** folder

   ```bash
   chmod 740 scripts/*
   ```

3. Run the infrastructure deployment script

   ```bash
   ./scripts/deploy-infrastructure.sh
   ```

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

7. Run the healh check script to confirm the services are healthy

   ```bash
   ./scripts/health-check.sh
   ```

8. Destroy the infrastructure by running the rollback script

   ```bash
   ./scripts/rollback.sh
   ```

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

- [x] Created instances
- [x] Created s3
- [ ] Created s3 for logging but having issues with access to the bucket
- [x] Scripts created and functional
- [x] Pipeline created and functional

---
