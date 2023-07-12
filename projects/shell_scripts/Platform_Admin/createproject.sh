
#!/bin/bash

# Usage: ./createproject.sh https://proservices.jfrog.io <platform-admin-token> vns1 group sv-project-admin-group
# ref: https://serverfault.com/questions/1135191/jq-error-x-0-is-not-defined-at-top-level-line-1
set -e
# Get Arguments
SOURCE_JPD_URL="${1:?Please enter the JPD URL. Example: https://proservices.jfrog.io}"
JPD_AUTH_TOKEN="${2:?Please provide the identity token}"
PROJECT_KEY="${3:?Please provide the project_key value}"
ADMIN_TYPE="${4:?Please provide the admin type (user or group)}"
PROJECT_ADMIN_NAME="${5:?Please provide the username or group name for the project admin}"


# JSON data
json_data='{
  "display_name": "venus1",
  "project_key": "{{ _.project_key }}",
  "description": "Venus project created via automation",
  "admin_privileges": {
    "manage_members": true,
    "manage_resources": true,
    "manage_security_assets": true,
    "index_resources": true,
    "allow_ignore_rules": true
  },
  "storage_quota_bytes": -1,
  "soft_limit": false,
  "storage_quota_email_notification": true
}'

# Replace project_key value using jq
updated_json=$(echo "$json_data" | jq --arg project_key "$PROJECT_KEY" '."project_key" = $project_key')

# Print the updated JSON
echo "$updated_json"

# Create the new project
project_response_code=$(curl -H "Authorization: Bearer $JPD_AUTH_TOKEN" \
                     -X POST \
                     -H "Content-Type: application/json" \
                     -w "%{http_code}" \
                     -o /dev/null \
                     -d "$updated_json" \
                     "$SOURCE_JPD_URL/access/api/v1/projects")


if [ "$project_response_code" != "201" ]; then
  echo "Failed to create the project $PROJECT_KEY ."
  exit 1
fi

echo "Project $project_key_created is created"

if [ "$ADMIN_TYPE" == "user" ]; then
  # Assign an existing user as a project admin to the newly created project
  admin_response_code=$(curl -H "Authorization: Bearer $JPD_AUTH_TOKEN" \
                     -X POST \
                     -H "Content-Type: application/json" \
                     -w "%{http_code}" \
                     -o /dev/null \
                     "$SOURCE_JPD_URL/access/api/v1/projects/$PROJECT_KEY/user/$PROJECT_ADMIN_NAME/admin")

elif [ "$ADMIN_TYPE" == "group" ]; then
  # Assign an existing group as a project admin to the newly created project
  admin_response_code=$(curl -H "Authorization: Bearer $JPD_AUTH_TOKEN" \
                     -X POST \
                     -H "Content-Type: application/json" \
                     -w "%{http_code}" \
                     -o /dev/null \
                     "$SOURCE_JPD_URL/access/api/v1/projects/$PROJECT_KEY/group/$PROJECT_ADMIN_NAME/admin")

else
  echo "Invalid admin type entered."
  exit 1
fi




if [ "$admin_response_code" != "204" ]; then
  echo "Failed to assign the project admin."
  exit 1
fi

echo "$ADMIN_TYPE $PROJECT_ADMIN_NAME is assigned as the project admin for Project with projectKey $PROJECT_KEY"
