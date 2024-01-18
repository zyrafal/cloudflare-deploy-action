#!/bin/bash

git clone https://github.com/${1} .
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20.10.0
nvm use 20.10.0
node --version
yarn install
yarn build
yarn add wrangler
IFS='/' read -ra fields <<< "${1}"
projectName="${fields[1]//./-}"
echo $projectName
yarn wrangler pages project list > project_list.txt
if grep -q $projectName project_list.txt; then
  echo "Project found"
else
  echo "Project not found"
  yarn wrangler pages project create "$projectName" --production-branch "${2}"
fi
yarn wrangler pages deploy "${3}" --project-name "$projectName"