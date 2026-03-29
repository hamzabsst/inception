#!/bin/bash

set -e

# Generate self-signed SSL certificate using runtime DOMAIN_NAME
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=Paris/L=Paris/O=Inception/CN=${DOMAIN_NAME}"
fi

# Substitute environment variables into NGINX config template
envsubst '$DOMAIN_NAME' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

# Start NGINX in the foreground
exec nginx -g "daemon off;"
