# StartTech Architecture

This document outlines the system design and infrastructure components for the StartTech full-stack application.

## System Overview

The application follows a decoupled architecture consisting of a React frontend, a Golang backend API, and managed data services.

## Component Breakdown

- **Frontend**: A **React** application hosted as a static site on **AWS S3**. Content is distributed globally via **Amazon CloudFront** to ensure low latency and SSL termination.

- **Backend API**: A **Golang** service containerized with **Docker**. It runs on **EC2 instances** managed by an **Auto Scaling Group (ASG)** to handle traffic fluctuations.

- **Load Balancing**: An **Application Load Balancer (ALB)** routes traffic to the backend target groups and performs health checks.

- **Caching**: **Amazon ElastiCache (Redis)** is utilized for session management and database query caching.

- **Database**: **MongoDB Atlas** provides the primary persistent data store.

- **Monitoring**: **Amazon CloudWatch** centralizes logs from the Golang API and tracks system metrics.

## CI/CD Pipeline Logic

- **Infrastructure Pipeline**: Automates the deployment of AWS resources using **Terraform**, and update github action secret using the terraform output.

- **Frontend Pipeline**: Triggered on code commits to build the React bundle, sync files to S3, and invalidate CloudFront caches.

- **Backend Pipeline**: Handles Dockerizing the Golang app, pushing images to Docker Hub, and performing rolling updates on the EC2 fleet.

---
