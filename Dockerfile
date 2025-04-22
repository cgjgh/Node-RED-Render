FROM nodered/node-red:latest-debian

# Install jq, curl, and cloudflared
USER root
RUN apt-get update && \
    apt-get install -y jq curl sudo && \
    mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list && \
    apt-get update && \
    apt-get install -y cloudflared

# Switch back to the default user
# USER node-red

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

# Remove Windows line endings in /data
RUN sed -i 's/\r$//' /data/entrypoint.sh

# Expose port 80
EXPOSE 80

# Set the custom script as the new entrypoint
ENTRYPOINT ["/data/entrypoint.sh"]
