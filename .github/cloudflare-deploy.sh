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

# Deployment
echo "Deploying project..."

curl --request POST \
  --url "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$REPOSITORY_NAME/deployments" \
  --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  --header "Content-Type: multipart/form-data" \
  --form "branch=$CURRENT_BRANCH" \
  --form "source=@$DIST"

# Note: Adjust the `source` form field to point to the actual build output or tarball as required by Cloudflare

echo "Deployment triggered successfully."
