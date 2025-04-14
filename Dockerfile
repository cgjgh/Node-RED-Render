FROM nodered/node-red:latest
COPY package.json /data/package.json
RUN cd /data && npm install
COPY flows.json /data/flows.json
COPY settings.js /data/settings.js