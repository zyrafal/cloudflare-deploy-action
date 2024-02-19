#!/bin/bash
set -e
PROJECT=$1
DEFAULT_BRANCH=$2
DIST=$3
CURRENT_BRANCH=$4

IFS='/' read -ra fields <<<"$PROJECT"
REPOSITORY_NAME="${fields[1]}"
REPOSITORY_NAME=${REPOSITORY_NAME//./-}
cd "$PROJECT" || exit

echo "PROJECT: $PROJECT"
echo "DEFAULT_BRANCH: $DEFAULT_BRANCH"
echo "DIST: $DIST"

ls
ls "$DIST"

echo "CURRENT_BRANCH: $CURRENT_BRANCH"
echo "REPOSITORY_NAME: $REPOSITORY_NAME"

yarn add wrangler -d --frozen-lockfile
if ! yarn wrangler pages project list | grep -q "$REPOSITORY_NAME"; then
  yarn wrangler pages project create "$REPOSITORY_NAME" --production-branch "$DEFAULT_BRANCH"
fi

output_url=$(yarn wrangler pages deploy "$DIST" --project-name "$REPOSITORY_NAME" --branch "$CURRENT_BRANCH" --commit-dirty=true)
output_url="${output_url//$'\n'/%0A}"
echo "DEPLOYMENT_URL=$output_url" >>"$GITHUB_ENV"
