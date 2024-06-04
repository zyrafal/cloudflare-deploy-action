#!/bin/bash
set -e
PROJECT=$1
DEFAULT_BRANCH=$2
DIST=$3
CURRENT_BRANCH=$4

IFS='/' read -ra fields <<<"$PROJECT"
REPOSITORY_NAME="${fields[1]}"
REPOSITORY_NAME=${REPOSITORY_NAME//./-}

echo "Checking if project exists..."

# Specifically scoped for public contributors to automatically deploy to our team Cloudflare account

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

if [ -d "$DIST/functions" ]; then
  echo "Found functions directory. Wrangler will deplooy it as backend."
  # If the functions directory is present
  # $DIST/functions directory is expected to contain Cloudflare Pages Functions.
  # $DIST/$DIST directory is expected to contain static files for Cloudflare Pages.

  # If there is no functions directory, everything in "$DIST" is
  # expected to be static files for Cloudflare Pages.
  # This ensures backward compatibility for existing static-only projects.

  cd "$DIST"
fi

if [ -f "package.json" ]; then
  yarn install --ignore-scripts
else
  yarn add wrangler
fi

output=$(yarn wrangler pages deploy "$DIST" --project-name "$REPOSITORY_NAME" --branch "$CURRENT_BRANCH" --commit-dirty=true)
output="${output//$'\n'/ }"
# Extracting URL from output only
url=$(echo "$output" | grep -o 'https://[^ ]*' | sed 's/ //g')
echo "DEPLOYMENT_OUTPUT=$output" >> "$GITHUB_ENV"
echo "DEPLOYMENT_URL=$url" >> "$GITHUB_ENV"
