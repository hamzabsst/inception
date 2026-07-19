#!/bin/bash

set -eu

WP_PATH="/var/www/html"


DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)


export MYSQL_PWD="${DB_PASSWORD}"
until mysqladmin ping -h "${DB_HOST%%:*}" -u "${DB_USER}" --silent 2>/dev/null; do
	echo "Waiting for MariaDB..."
	sleep 2
done
unset MYSQL_PWD


if [ ! -f "${WP_PATH}/wp-config.php" ]; then

	wp core download --allow-root --path="${WP_PATH}"

	wp config create --allow-root \
		--path="${WP_PATH}" \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="${DB_HOST}"


	wp core install \
		--allow-root \
		--path="${WP_PATH}" \
		--url="https://${DOMAIN_NAME}:8443" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email


	if ! wp user get "${WP_USER}" --allow-root --path="${WP_PATH}" >/dev/null 2>&1; then
		wp user create \
			--allow-root \
			--path="${WP_PATH}" \
			"${WP_USER}" "${WP_USER_EMAIL}" \
			--role=author \
			--user_pass="${WP_USER_PASSWORD}"
	fi
fi


mkdir -p /run/php
chown www-data:www-data /run/php

exec php-fpm7.4 -F
