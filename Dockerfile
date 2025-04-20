FROM nodered/node-red:latest

# Copy package.json with correct ownership and install dependencies
COPY --chown=node-red:node-red package.json /data/package.json
RUN cd /data && npm install

# Copy settings.js with correct ownership
COPY --chown=node-red:node-red settings.js /data/settings.js

# Copy all files prefixed with .config with correct ownership
COPY --chown=node-red:node-red .config* /data/

# Create the empty project directory with correct ownership
RUN mkdir -p /data/projects/nodered_render && chown node-red:node-red /data/projects/nodered_render

# Copy the custom entrypoint script
COPY --chown=node-red:node-red entrypoint.sh /data/entrypoint.sh
RUN chmod +x /data/entrypoint.sh

# Set the custom script as the new entrypoint
ENTRYPOINT ["/data/entrypoint.sh"]
