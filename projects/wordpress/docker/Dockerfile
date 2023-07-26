FROM nginx:latest

# Set env variables
ARG DOMAIN

# Install necessary packages for certbot and nginx
RUN apt-get update && \
    apt-get install -y certbot python3-certbot-nginx

# Copy nginx config file
COPY ./nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template

# Get the initial certificate (replace with your domain and email)
RUN service nginx start && \
    certbot --test-cert --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect -v
