FROM node:18-alpine AS frontend_build

WORKDIR /app/src

# Copy only the package.json and package-lock.json first.

COPY src/package*.json ./

# Install frontend dependencies.

RUN npm install

# Copy the rest of the React application's source code.

COPY src/ ./

RUN npm run build

EXPOSE 80

#backend

FROM node:18-alpine AS backend_build



# Set the working directory for the backend application.

WORKDIR /app/src

COPY package*.json ./

RUN npm install 


# Copy the Node.js server file.

COPY server.js .

COPY public ./public

EXPOSE 3000

-----------

# Stage 3: Final Production Image (Nginx + Node.js)


FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom Nginx configuration.

# Ensure 'nginx.conf' is in the same directory as this Dockerfile.

COPY nginx.conf /etc/nginx/nginx.conf


COPY --from=frontend_build /app/src/build /usr/share/nginx/html


# Create a directory for the Node.js backend application.

RUN mkdir -p /usr/src/app


COPY --from=backend_build /app/src /usr/src/app


# Ensure 'entrypoint.sh' is in the same directory as this Dockerfile.

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh


# Set the entrypoint script as the default command to run when the container starts.

CMD ["/entrypoint.sh"]
