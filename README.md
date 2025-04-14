# Node-RED Deployment

This repository deploys Node-RED using Docker.

## Deploy to Render
1. Create a new web service on Render.
2. Link this GitHub repository.
3. Deploy using the `render.yaml` configuration.

## Deploy to a VPS or Local Machine
1. Clone this repository.
2. Build the image: `docker build -t my-node-red .`
3. Run the container: `docker run -d -p 1880:1880 my-node-red`