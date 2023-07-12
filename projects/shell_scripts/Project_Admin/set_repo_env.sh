#!/bin/bash

# Usage: bash ./set_repo_env.sh https://proservices.jfrog.io <project-admin-token> vns1 uat1,stage1
# Usage: bash ./set_repo_env.sh https://proservices.jfrog.io  $PROJECT_ADMIN_TOKEN vns1-sv-generic-local vns1-stage1
# ref: https://serverfault.com/questions/1135191/jq-error-x-0-is-not-defined-at-top-level-line-1
set -e
# Get Arguments
SOURCE_JPD_URL="${1:?Please enter the JPD URL. Example: https://proservices.jfrog.io}"
JPD_AUTH_TOKEN="${2:?Please provide the identity token}"
REPO_KEY="${3:?Please provide the project_key value}"
PROJECT_ENV="${4:?Please provide a project environment to map the repo to. From 7.53.1 onward, only one value is allowed}"

repo_config_json=$(curl -H "Authorization: Bearer $JPD_AUTH_TOKEN" \
                     -X GET \
                     "$SOURCE_JPD_URL/artifactory/api/repositories/$REPO_KEY")
echo "repo config is = $repo_config_json"

# Replace "environments" value using jq
#updated_json=$(echo "$json_data" | jq --arg project_key "$PROJECT_KEY" '."project_key" = $project_key')
updated_repo_config_json=$(echo "$repo_config_json" | jq --arg project_env "$PROJECT_ENV" '."environments" = [$project_env]')

# Print the updated JSON
echo "updated repo config is = $updated_repo_config_json"

# Update the repo "environments"
repo_response_code=$(curl -H "Authorization: Bearer $JPD_AUTH_TOKEN" \
                     -X POST \
                     -H "Content-Type: application/json" \
                     -w "%{http_code}" \
                     -o /dev/null \
                     -d "$updated_repo_config_json" \
                     "$SOURCE_JPD_URL/artifactory/api/repositories/$REPO_KEY")

echo "repo_response_code is = $repo_response_code"
if [ "$repo_response_code" != "200" ]; then
  echo "Failed to set the environment $PROJECT_ENV to repo $REPO_KEY ."
  exit 1
fi

echo "Repo $REPO_KEY is now mapped to environment $PROJECT_ENV"