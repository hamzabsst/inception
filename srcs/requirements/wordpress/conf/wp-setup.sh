#!/bin/bash

set -e

# Wait for MariaDB to become available
i=0
while ! mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 30 ]; then
        echo "MariaDB is not reachable after 30 seconds" >&2
        exit 1
    fi
    sleep 1
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --path=/var/www/html --allow-root

    wp config create \
        --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --path=/var/www/html \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root
fi

mkdir -p /run/php
exec php-fpm7.4 -F
