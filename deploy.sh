#!/bin/bash

# Load configuration from environment file (not committed to Git)
source /opt/deploy-secrets/.env

# Default values
PORTAINER_URL="${PORTAINER_URL:-http://localhost:9000}"
PROJECT_DIR="${PROJECT_DIR:-/opt/my-first-deploy}"

# Logging function
log() {
    echo "$(date): $1" | tee -a /var/log/deploy.log
}

# Check required environment variables
if [ -z "$PORTAINER_TOKEN" ] || [ -z "$STACK_ID" ]; then
    log "ERROR: Missing required environment variables"
    log "Please ensure PORTAINER_TOKEN and STACK_ID are set in /opt/deploy-secrets/.env"
    exit 1
fi

log "Starting deployment"

# Go to project directory
cd $PROJECT_DIR

# Pull latest code
log "Pulling latest code from Git"
git pull origin main

# Restart the stack using Portainer API
log "Restarting Portainer stack ID: $STACK_ID"
curl -X POST \
     -H "X-API-Key: $PORTAINER_TOKEN" \
     "$PORTAINER_URL/api/stacks/$STACK_ID/start"

# Wait a moment for restart
sleep 5

# Verify the site is responding
if curl -s http://localhost:8080 > /dev/null; then
    log "Deployment successful - site is responding"
else
    log "WARNING: Site may not be responding correctly"
fi

log "Deployment complete"