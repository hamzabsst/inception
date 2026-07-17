#!/bin/bash

set -eu

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Support both plain env vars and Docker secrets (_FILE convention)
file_env() {
	var="$1"
	file_var="${var}_FILE"
	if [ "${!file_var:-}" ]; then
		export "$var"="$(cat "${!file_var}")"
	fi
}
file_env MYSQL_ROOT_PASSWORD
file_env MYSQL_PASSWORD

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "First startup: initializing MariaDB data directory"

	mysql_install_db \
		--user=mysql \
		--datadir=/var/lib/mysql \
		> /dev/null

	# Start mariadbd temporarily (no networking) so we can run the
	# setup SQL, then shut it down before exec'ing the real,
	# foreground process that becomes PID 1's actual server.
	mysqld_safe --datadir=/var/lib/mysql --skip-networking &

	# Wait until the temporary server is ready to accept commands
	until mysqladmin ping >/dev/null 2>&1; do
		sleep 1
	done

	mysql -u root <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOSQL

	mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
	echo "First startup: initialization complete"
fi

exec "$@"
