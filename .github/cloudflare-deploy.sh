#!/bin/bash
set -e
PROJECT=$1
DEFAULT_BRANCH=$2
DIST=$3
CURRENT_BRANCH=$4

IFS='/' read -ra fields <<<"$PROJECT"
REPOSITORY_NAME="${fields[1]}"
REPOSITORY_NAME=${REPOSITORY_NAME//./-}

echo "PROJECT: $PROJECT"
echo "DEFAULT_BRANCH: $DEFAULT_BRANCH"
echo "DIST: $DIST"

echo "Hard coding repository name for testing"
echo "Before REPOSITORY_NAME: $REPOSITORY_NAME"
REPOSITORY_NAME="ts-template"
echo "After REPOSITORY_NAME: $REPOSITORY_NAME"

echo "Checking if project exists..."

CLOUDFLARE_ACCOUNT_ID="17b9dfa79e16b79dffcb11a66768539c"

# Fetch the list of projects and check if the specific project exists
project_exists=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r ".result[] | select(.name == \"$REPOSITORY_NAME\") | .name")

if [ "$project_exists" == "$REPOSITORY_NAME" ]; then
  echo "Project already exists. Skipping creation..."
else
  echo "Project does not exist. Creating new project..."
  # Curl command to create a new project
  curl -X POST "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"name\":\"$REPOSITORY_NAME\",\"production_branch\":\"$DEFAULT_BRANCH\",\"build_config\":{\"build_command\":\"\",\"destination_dir\":\"$DIST\"}}"
fi

# Create a tarball of the build directory
tarball="deployment-$(date +%Y-%m-%d-%H-%M-%S).tar.gz"
tar -czf "../$tarball" .

# Deploy using the Cloudflare API
response=$(curl -s -w "%{http_code}" -o /tmp/cf_response.txt --request POST \
  --url "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$REPOSITORY_NAME/deployments" \
  --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  --header "Content-Type: multipart/form-data" \
  --form "branch=$CURRENT_BRANCH" \
  --form "source=@../$tarball")

http_status=$(tail -n1 <<<"$response") # Extract the HTTP status code from the response

# Check the response
if [ "$http_status" -eq 200 ] || [ "$http_status" -eq 201 ]; then
  echo "Deployment successful."
else
  echo "Failed to deploy the project. HTTP status: $http_status"
  echo "Response body:"
  cat /tmp/cf_response.txt
  exit 1
fi
