#!/bin/bash

set -e

# Variables
SERVER_HOST_IP="13.40.98.190"
SERVER_USER="ubuntu"
DOCKER_USER="philipoyelegbin"
DOCKER_IMAGE="muchtodo:latest"
FULL_IMAGE_NAME="$DOCKER_USER/$DOCKER_IMAGE"
CONTAINER_NAME="muchtodo"
SSH_KEY="terraform/id_rsa"
REMOTE_PATH="/home/ubuntu/MuchToDo"

echo "--- Deploying MuchToDo backend to $SERVER_HOST_IP ---"

# 1. Build and Push (Local)
echo "Building and pushing $FULL_IMAGE_NAME..."
# Ensure you are logged in to Docker Hub before running this
docker build -t "$FULL_IMAGE_NAME" backend/
docker push "$FULL_IMAGE_NAME"

# 2. Prepare Remote Directory
echo "Preparing remote directory..."
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST_IP" "mkdir -p $REMOTE_PATH"

# 3. Securely Copy .env file
echo "Uploading .env file..."
scp -o StrictHostKeyChecking=no -i "$SSH_KEY" backend/MuchToDo/.env "$SERVER_USER@$SERVER_HOST_IP:$REMOTE_PATH/.env"

# 4. Remote Execution (Pull and Run)
# Using 'EOF' with quotes ensures variables inside are NOT expanded by your local machine
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST_IP" << 'EOF'
    set -e
    
    # Define variables inside the remote shell
    CONTAINER_NAME="muchtodo"
    FULL_IMAGE_NAME="philipoyelegbin/muchtodo:latest"
    REMOTE_PATH="/home/ubuntu/MuchToDo"

    echo "Pulling latest image..."
    sudo docker pull "$FULL_IMAGE_NAME"

    echo "Stopping and removing existing container..."
    sudo docker rm -f "$CONTAINER_NAME" || true

    echo "Running new container..."
    # Note the use of the full image name here
    sudo docker run -d \
      --restart unless-stopped \
      -v "$REMOTE_PATH/.env:/app/.env:ro" \
      -p 80:8080 \
      --name "$CONTAINER_NAME" \
      "$FULL_IMAGE_NAME"

    echo "Container status:"
    sudo docker ps -f name="$CONTAINER_NAME"
EOF

echo "--- MuchToDo backend deployed and running on http://$SERVER_HOST_IP 🎉 ---"
