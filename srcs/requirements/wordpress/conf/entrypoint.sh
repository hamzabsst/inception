#!/bin/bash

set -eu

WORDPRESS_DIR="/var/www/html"


WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)


export MYSQL_PWD="${WORDPRESS_DB_PASSWORD}"
until mysqladmin ping -h "${WORDPRESS_DB_HOST%%:*}" -u "${WORDPRESS_DB_USER}" --silent 2>/dev/null; do
	echo "Waiting for MariaDB..."
	sleep 2
done
unset MYSQL_PWD


if [ ! -f "${WORDPRESS_DIR}/wp-config.php" ]; then
	if [ ! -f "${WORDPRESS_DIR}/wp-load.php" ]; then
		wp core download --allow-root --path="${WORDPRESS_DIR}"
	fi

	wp config create \
		--allow-root \
		--path="${WORDPRESS_DIR}" \
		--dbname="${WORDPRESS_DB_NAME}" \
		--dbuser="${WORDPRESS_DB_USER}" \
		--dbpass="${WORDPRESS_DB_PASSWORD}" \
		--dbhost="${WORDPRESS_DB_HOST}"


	wp core install \
		--allow-root \
		--path="${WORDPRESS_DIR}" \
		--url="${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email


	if ! wp user get "${WP_USER}" --allow-root --path="${WORDPRESS_DIR}" >/dev/null 2>&1; then
		wp user create \
			--allow-root \
			--path="${WORDPRESS_DIR}" \
			"${WP_USER}" "${WP_USER_EMAIL}" \
			--role=author \
			--user_pass="${WP_USER_PASSWORD}"
	fi
fi


mkdir -p /run/php
chown www-data:www-data /run/php

exec php-fpm7.4 -F
