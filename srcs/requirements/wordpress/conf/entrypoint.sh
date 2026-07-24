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
fi

if ! wp core is-installed --allow-root --path="${WP_PATH}" 2>/dev/null; then
	wp core install \
		--allow-root \
		--path="${WP_PATH}" \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email
fi

if [ ! -f "${WP_PATH}/.provisioned" ]; then
	# remove default content
	wp post delete 1 --force --allow-root --path="${WP_PATH}" 2>/dev/null || true
	wp post delete 2 --force --allow-root --path="${WP_PATH}" 2>/dev/null || true  

	# create a real homepage
	HOME_ID=$(wp post create --allow-root --path="${WP_PATH}" \
		--post_type=page --post_title="Home" \
		--post_content="Welcome to hbousset Inception project." \
		--post_status=publish --porcelain)

	wp option update show_on_front page --allow-root --path="${WP_PATH}"
	wp option update page_on_front "${HOME_ID}" --allow-root --path="${WP_PATH}"

	touch "${WP_PATH}/.provisioned"
fi

REDIS_PASSWORD=$(cat /run/secrets/redis_password)

if ! wp plugin is-installed redis-cache --allow-root --path="${WP_PATH}"; then
	wp plugin install redis-cache --activate --allow-root --path="${WP_PATH}"
	wp config set WP_REDIS_HOST redis --allow-root --path="${WP_PATH}"
	wp config set WP_REDIS_PASSWORD "${REDIS_PASSWORD}" --allow-root --path="${WP_PATH}"
	wp redis enable --allow-root --path="${WP_PATH}"
fi

if ! wp user get "${WP_USER}" --allow-root --path="${WP_PATH}" >/dev/null 2>&1; then
	wp user create \
		--allow-root \
		--path="${WP_PATH}" \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="${WP_USER_PASSWORD}"
fi


mkdir -p /run/php
chown www-data:www-data /run/php

exec php-fpm7.4 -F