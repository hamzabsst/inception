#!/bin/bash

set -e

mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FR/ST=Paris/L=Paris/O=Inception/CN=${DOMAIN_NAME}"

envsubst '$DOMAIN_NAME' \
	< /etc/nginx/conf.d/default.conf.template \
	> /etc/nginx/conf.d/default.conf


exec nginx -g "daemon off;"
