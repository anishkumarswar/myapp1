FROM node:18-alpine AS build_stage

WORKDIR /app/src

# Copy only the package.json and package-lock.json first.

COPY src/package*.json ./

RUN npm install

# Copy the rest of the React application's source code.

COPY src/ ./

RUN npm run build

-----------

# Stage 2: Final Production Image (Nginx + Node.js)


FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom Nginx configuration.

COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=build_stage /app/src/build /usr/share/nginx/html

# Create a dedicated directory for the Node.js backend application.
RUN mkdir -p /usr/src/app

COPY --from=build_stage /app/src/node_modules /usr/src/app/node_modules
COPY --from=build_stage /app/src/package*.json /usr/src/app/ 
COPY server.js /usr/src/app/server.js
COPY public/ /usr/src/app/public/

EXPOSE 80    #for nginx

EXPOSE 3000  #for node

# Ensure 'entrypoint.sh' is in the same directory as this Dockerfile.

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh


# Set the entrypoint script as the default command to run when the container starts.

CMD ["/entrypoint.sh"]
