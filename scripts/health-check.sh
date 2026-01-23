#1 /bin/bash

set -e

# Variables
CONTAINER_NAME="muchtodo"
LOAD_BALANCER_URL="muchtodo-app-lb-581292386.eu-west-2.elb.amazonaws.com"   # Replace with your Load Balancer DNS
CLOUDFRONT_URL="d19a0ryp66qqyq.cloudfront.net"  # Replace with your CloudFront Distribution Domain Name

echo "---Starting health checks for MuchToDo application ---"

# Health check for MuchToDo backend
echo "Performing health check on MuchToDo backend..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$LOAD_BALANCER_URL/health")
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "MuchToDo backend is healthy and running."
else
    echo "Health check failed! MuchToDo backend is not responding as expected. HTTP Status: $HTTP_STATUS"
fi

# Health check for MuchToDo frontend
echo "Performing health check on MuchToDo frontend..."
FRONTEND_HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$CLOUDFRONT_URL/health")
if [ "$FRONTEND_HTTP_STATUS" -eq 200 ]; then
    echo "MuchToDo frontend is healthy and running."
else
    echo "Health check failed! MuchToDo frontend is not responding as expected. HTTP Status: $FRONTEND_HTTP_STATUS"
fi

echo "--- MuchToDo application health checks completed 🎉 ---"