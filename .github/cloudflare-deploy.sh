#!/bin/bash
set -e

# Get the repository, production branch, and output directory from the command line arguments
repository=$1
productionBranch=$2
builtProjectDirectory=$3

# Extract the organization name and repository name from the repository variable
IFS='/' read -ra fields <<<"$repository"
# organizationName="${fields[0]}"
repositoryName="${fields[1]}"

repositoryName=${repositoryName//./-}

# Change directory to the repository root
cd "$repository" || exit

yarn add wrangler -d --frozen-lockfile
# wrangler_path=$(yarn bin)/wrangler # /opt/hostedtoolcache/node/20.10.0/x64/bin/wrangler
# export PATH="$PATH:$wrangler_path"

if ! yarn wrangler pages project list | grep -q "$repositoryName"; then
  echo "Project not found"
  yarn wrangler pages project create "$repositoryName" --production-branch "$productionBranch"
fi

output_url=$(yarn wrangler pages deploy "$builtProjectDirectory" --project-name "$repositoryName" --branch "$productionBranch" --commit-dirty=true)

output_url="${output_url//$'\n'/%0A}"
echo "DEPLOYMENT_URL=$output_url" >>"$GITHUB_ENV"
