#!/bin/bash

set -eu

# Read passwords from secrets if available, otherwise from environment
if [ -f "/run/secrets/db_root_password" ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi

if [ -f "/run/secrets/db_password" ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

# Start MariaDB without networking to set up the database
service mariadb start

# Wait for MariaDB to be ready
until mysqladmin ping --silent; do
    sleep 1
done

# Create database and user if they do not exist
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Stop the temporary MariaDB instance (use MYSQL_PWD to avoid password in args)
MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysqladmin -u root shutdown

# Restart MariaDB in the foreground
exec mysqld_safe
