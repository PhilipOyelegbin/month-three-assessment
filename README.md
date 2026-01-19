# Month 3 Assessment - Full-Stack CI/CD Pipeline Implementation

Created a comprehensive CI/CD pipeline that automates the entire deployment process from code commit to production, including proper monitoring and security practices.

```bash
# Command to start the docker backend app
docker run -d -v $(pwd)/MuchToDo/.env:/app/.env:ro -p 3000:8080 --name muchtodo muchtodo-v1:latest
```

- [x] Created instances
- [x] Created s3
- [ ] Created s3 for logging but having issues with access to the bucket
