#!/bin/bash
set -eu

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

echo -e "[mysqld]\nbind-address = 0.0.0.0" > /etc/mysql/mariadb.conf.d/50-server.cnf

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "First startup: initializing MariaDB data directory"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld_safe --datadir=/var/lib/mysql --skip-networking &
    until mysqladmin ping >/dev/null 2>&1; do sleep 1; done

    mysql -u root << EOF
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

exec "$@"