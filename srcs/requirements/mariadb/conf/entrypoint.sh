#!/bin/bash

set -eu

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

MYSQL_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "First startup: initializing MariaDB data directory"

	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	mysqld_safe --datadir=/var/lib/mysql --skip-networking &
	until mysqladmin ping >/dev/null 2>&1; do
		sleep 1
	done

	mysql -u root << EOF
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
EOF

	mysqladmin -u root shutdown
	echo "First startup: initialization complete"
fi

exec "$@"
