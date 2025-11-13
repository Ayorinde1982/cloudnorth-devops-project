# Use the official lightweight Nginx image from Docker Hub
FROM nginx:1.21.6-alpine

# Copy our custom Nginx configuration to the correct location in the image
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy our website's HTML file to the directory Nginx serves from
COPY index.html /usr/share/nginx/html

# Expose port 80 to allow traffic to the web server
EXPOSE 80
