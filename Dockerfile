FROM nodered/node-red:latest

# Install jq
USER root
RUN apk add --no-cache jq

# Switch back to the default user
USER node-red

# Copy package.json with correct ownership and install dependencies
COPY --chown=node-red:node-red package.json /data/package.json
RUN cd /data && npm install
RUN cd /data && npm install --save passport-google-oauth20

# Copy settings.js with correct ownership
COPY --chown=node-red:node-red settings.js /data/settings.js

# Copy all files prefixed with .config with correct ownership
COPY --chown=node-red:node-red .config* /data/

# Create the empty project directory with correct ownership
RUN mkdir -p /data/projects/nodered_render && chown node-red:node-red /data/projects/nodered_render

# Copy the custom entrypoint script
COPY --chown=node-red:node-red entrypoint.sh /data/entrypoint.sh
RUN chmod +x /data/entrypoint.sh

# Remove Windows line endings in /data
RUN sed -i 's/\r$//' /data/entrypoint.sh

# Set the custom script as the new entrypoint
ENTRYPOINT ["/data/entrypoint.sh"]
