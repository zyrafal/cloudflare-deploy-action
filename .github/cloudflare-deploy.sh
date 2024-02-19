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
yarn wrangler pages --help

find ../../.. -type d \( -name "node_modules" -o -name ".git" -o -name ".husky" \) -prune -o -print

account_id="17b9dfa79e16b79dffcb11a66768539c" # Ubiquity DAO Workers

wrangler_file_path="../wrangler.toml"

if grep -q "account_id" "$wrangler_file_path"; then
  sed -i "s/account_id = \".*\"/account_id = \"$account_id\"/g" "$wrangler_file_path"
else
  echo "account_id = \"$account_id\"" >>"$wrangler_file_path"
fi

if yarn wrangler pages project list | grep -q "$repositoryName"; then
  echo "Project found"
else
  echo "Project not found"
  yarn wrangler pages project create "$repositoryName" --production-branch "$productionBranch"
fi

if [ "$productionBuild" = "true" ]; then
  output_url=$(npx wrangler pages deploy "$builtProjectDirectory" --project-name "$repositoryName" --commit-dirty=true)
else
  output_url=$(npx wrangler pages preview "$builtProjectDirectory" --project-name "$repositoryName")
fi

output_url="${output_url//$'\n'/%0A}"
# echo "DEPLOYMENT_URL=$output_url" >>"$GITHUB_ENV"
