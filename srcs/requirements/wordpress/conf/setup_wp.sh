#!/bin/bash

set -eu

WORDPRESS_DIR="/var/www/html"

# Wait for MariaDB to be ready (use MYSQL_PWD to avoid password in process list)
export MYSQL_PWD="${WORDPRESS_DB_PASSWORD}"
until mysqladmin ping -h "${WORDPRESS_DB_HOST%%:*}" -u "${WORDPRESS_DB_USER}" --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done
unset MYSQL_PWD

# Download WordPress if not already present
if [ ! -f "${WORDPRESS_DIR}/wp-config.php" ]; then
    # Download WordPress core
    wp core download --allow-root --path="${WORDPRESS_DIR}"

    # Create wp-config.php
    wp config create \
        --allow-root \
        --path="${WORDPRESS_DIR}" \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}"

    # Install WordPress
    wp core install \
        --allow-root \
        --path="${WORDPRESS_DIR}" \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    # Create a regular user
    wp user create \
        --allow-root \
        --path="${WORDPRESS_DIR}" \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}"
fi

# Start PHP-FPM in the foreground
exec php-fpm7.4 -F
