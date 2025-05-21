#!/bin/sh

# Start the backend (Node.js server) in the background
nohup node /usr/src/app/server.js &

# Start Nginx in the foreground
nginx -g "daemon off;"
