#!/bin/bash

# Usage: bash ./create_env.sh https://proservices.jfrog.io <project-admin-token> vns1 uat1,stage1
# ref: https://serverfault.com/questions/1135191/jq-error-x-0-is-not-defined-at-top-level-line-1
set -e
# Get Arguments
SOURCE_JPD_URL="${1:?Please enter the JPD URL. Example: https://proservices.jfrog.io}"
JPD_AUTH_TOKEN="${2:?Please provide the identity token}"
PROJECT_KEY="${3:?Please provide the project_key value}"
PROJECT_ENV="${4:?Please provide the project environment to add (comma-separated)}"

IFS=',' read -ra ENV_ARRAY <<< "$PROJECT_ENV"

for environment in "${ENV_ARRAY[@]}"; do
  # Create a new environment with a name as $project-key-UAT
  curl -H "Authorization: Bearer $JPD_AUTH_TOKEN" \
    -X POST \
    -H "Content-Type: application/json" \
    "$SOURCE_JPD_URL/access/api/v1/projects/$PROJECT_KEY/environments" \
    -d '{ "name": "'"$PROJECT_KEY-$environment"'"}'
done
