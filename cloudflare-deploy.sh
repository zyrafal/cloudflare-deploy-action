#!/bin/bash
set -e

# Get the repository, production branch, and output directory from the command line arguments
repository=$1
production_branch=$2
output_directory=$3
extra_secrets=$4

# Deserialize the secrets JSON object and export each one
for key in $(echo "$extra_secrets" | jq -r 'keys[]'); do
  export "$key"="$(echo "$extra_secrets" | jq -r --arg key "$key" '.[$key]')"
done

# Change directory to the repository root
cd "$(basename "${repository}")" || exit

# Install Node.js and Yarn
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20.10.0
nvm use 20.10.0
node --version
yarn install
yarn build
yarn add wrangler

# Get the project name by replacing '.' with '-' in the repository name
IFS='/' read -ra fields <<<"$repository"
projectName="${fields[1]//./-}"
echo "$projectName"

# Check if the project already exists
yarn wrangler pages project list >project_list.txt
if grep -q "$projectName" project_list.txt; then
  echo "Project found"
else
  echo "Project not found"
  yarn wrangler pages project create "$projectName" --production-branch "$production_branch"
fi

# Deploy the project
yarn wrangler pages deploy "$output_directory" --project-name "$projectName"
