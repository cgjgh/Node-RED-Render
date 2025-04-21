#!/bin/bash

# Hash the Node-RED admin password using bcrypt and store it in an environment variable.
# This is used for securing the Node-RED admin interface.
echo "Hashing Node-RED admin password..."
export NODE_RED_ADMIN_HASHED_PASS=$(node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" "$NODE_RED_ADMIN_PASS")

# Replace the placeholder for the Node-RED credential secret in the configuration file.
# This ensures that the credential secret is set correctly for Node-RED projects.
echo "Replacing Node-RED credential secret in configuration file..."
sed -i "s|NODE_RED_CREDENTIAL_SECRET|$NODE_RED_CREDENTIAL_SECRET|g" /data/.config.projects.json

# Check if the Node-RED project repository has already been cloned.
# If not, clone the repository from GitHub using the provided token and repository name.
if [ ! -d /data/projects/nodered_render/.git ]; then
    if [ -n "$REPO_BRANCH" ]; then
        echo "Cloning repository with branch: $REPO_BRANCH"
        git clone --branch "$REPO_BRANCH" https://$GITHUB_TOKEN@github.com/$REPO_FULL_NAME.git /data/projects/nodered_render
    else
        echo "Cloning repository with main branch"
        git clone https://$GITHUB_TOKEN@github.com/$REPO_FULL_NAME.git /data/projects/nodered_render
    fi

    # Check if the clone was successful
    if [ -d /data/projects/nodered_render/.git ]; then
        echo "Repository cloned successfully."

        # Get the dependencies from the cloned project's package.json
        dependencies=$(jq -r '.dependencies | to_entries | map("\(.key)@\(.value)") | join(" ")' /data/projects/nodered_render/package.json)
        
        # Install dependencies from the cloned project's package.json into /data/
        echo "Installing project dependencies..."
        echo "Dependencies: $dependencies"
        npm install $dependencies --prefix /data/ /data/ --no-audit --no-update-notifier --no-fund --save --save-prefix=~ --omit=dev --engine-strict

        # Configure the Git user name and email for the cloned repository.
        # This is necessary for any Git operations that require user information.
        echo "Configuring Git user details..."
        git -C /data/projects/nodered_render config user.name "$GIT_USER_NAME"
        git -C /data/projects/nodered_render config user.email "$GIT_USER_EMAIL"
    else
        echo "Failed to clone the repository. Exiting."
        exit 1
    fi
else
    echo "Repository already cloned."
fi

# Execute the Node-RED entrypoint script with any additional arguments passed to this script.
# This starts the Node-RED application.
exec /usr/src/node-red/entrypoint.sh "$@"