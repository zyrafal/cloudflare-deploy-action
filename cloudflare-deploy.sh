#!/bin/bash
set -e

# Get the repository, production branch, and output directory from the command line arguments
repository=$1
production_branch=$2
output_directory=$3
is_production=$4

# Change directory to the repository root
cd "$(basename "${repository}")" || exit

# Get the project name by replacing '.' with '-' in the repository name
IFS='/' read -ra fields <<<"$repository"
projectName="${fields[1]//./-}"
echo "$projectName"

# Check if the project already exists
if yarn wrangler pages project list | grep -q "$projectName"; then
  echo "Project found"
else
  echo "Project not found"
  yarn wrangler pages project create "$projectName" --production-branch "$production_branch"
fi

# Deploy the project
if [ "$is_production" = "true" ]; then
  echo "Deploying to production"
  yarn wrangler pages deploy "$output_directory" --project-name "$projectName" --commit-dirty=true
else
  echo "Deploying a preview"
  yarn wrangler pages preview "$output_directory" --project-name "$projectName"
fi
