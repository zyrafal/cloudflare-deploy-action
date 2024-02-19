#!/bin/bash
set -e

# Get the repository, production branch, and output directory from the command line arguments
repository=$1
productionBranch=$2
builtProjectDirectory=$3
productionBuild=$4

# Extract the organization name and repository name from the repository variable
IFS='/' read -ra fields <<<"$repository"
organizationName="${fields[0]}"
repositoryName="${fields[1]}"

# Change directory to the repository root
cd "$organizationName/$repositoryName" || exit

yarn add tsx wrangler -d --frozen-lockfile
wrangler_path=$(yarn bin)/wrangler # /opt/hostedtoolcache/node/20.10.0/x64/bin/wrangler
export PATH="$PATH:$wrangler_path"

if yarn wrangler pages project list | grep -q "$repositoryName"; then
  echo "Project found"
else
  echo "Project not found"
  yarn wrangler pages project create "$repositoryName" --production-branch "$productionBranch"
fi

# yarn wrangler --version
# npx wrangler --version
# npx wrangler --help
# npx wrangler pages --help
# npx wrangler pages deploy --help
# npx wrangler pages dev --help

if [ "$productionBuild" = "true" ]; then
  echo "Deploying to production"
  yarn wrangler pages deploy --help
  # yarn wrangler pages deploy "$builtProjectDirectory" --project-name "$repositoryName" --commit-dirty=true
  output_url=$(yarn wrangler pages deploy "$builtProjectDirectory" --project-name "$repositoryName" --commit-dirty=true)
else
  echo "Deploying to preview"
  # yarn wrangler pages dev --help
  # yarn wrangler pages dev "$builtProjectDirectory" --project-name "$repositoryName"
  output_url=$(yarn wrangler pages deploy "$builtProjectDirectory" --project-name "$repositoryName" --branch staging)
fi

output_url="${output_url//$'\n'/%0A}"
# echo "DEPLOYMENT_URL=$output_url" >>"$GITHUB_ENV"
