#!/bin/bash

# Hash the Node-RED admin password using bcrypt and store it in an environment variable.
# This is used for securing the Node-RED admin interface.
export NODE_RED_ADMIN_HASHED_PASS=$(node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" "$NODE_RED_ADMIN_PASS")

# Replace the placeholder for the Node-RED credential secret in the configuration file.
# This ensures that the credential secret is set correctly for Node-RED projects.
sed -i "s|NODE_RED_CREDENTIAL_SECRET|$NODE_RED_CREDENTIAL_SECRET|g" /data/.config.projects.json

# Check if the Node-RED project repository has already been cloned.
# If not, clone the repository from GitHub using the provided token and repository name.
if [ ! -d /data/projects/nodered_render/.git ]; then
    if [ -n "$REPO_BRANCH" ]; then
        git clone --branch "$REPO_BRANCH" https://$GITHUB_TOKEN@github.com/$REPO_FULL_NAME.git /data/projects/nodered_render
    else
        git clone https://$GITHUB_TOKEN@github.com/$REPO_FULL_NAME.git /data/projects/nodered_render
    fi
fi

# Configure the Git user name and email for the cloned repository.
# This is necessary for any Git operations that require user information.
git -C /data/projects/nodered_render config user.name "$GIT_USER_NAME"
git -C /data/projects/nodered_render config user.email "$GIT_USER_EMAIL"

# Execute the Node-RED entrypoint script with any additional arguments passed to this script.
# This starts the Node-RED application.
exec /usr/src/node-red/entrypoint.sh "$@"
