#!/bin/bash
set -e

# Get the repository, production branch, and output directory from the command line arguments
repository=$1
productionBranch=$2
builtProjectDirectory=$3
productionBuild=$4

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
  yarn wrangler pages project create "$projectName" --production-branch "$productionBranch"
fi

# Deploy the project
if [ "$productionBuild" = "true" ]; then
  echo "Deploying to production"
  output_url=$(yarn wrangler pages deploy "$builtProjectDirectory" --project-name "$projectName" --commit-dirty=true)
else
  echo "Deploying a preview"
  output_url=$(yarn wrangler pages preview "$builtProjectDirectory" --project-name "$projectName")
fi

output_url="${output_url//$'\n'/%0A}"
echo "DEPLOYMENT_URL=$output_url" >> "$GITHUB_ENV"