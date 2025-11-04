#!/bin/sh

set -e #exit when ever error

#bootstrap mode -> run sql init from heredoc
mariadbd --user=mysql --bootstrap <<EOF
	USE mysql;
	FLUSH PRIVILEGES;
	
	CREATE DATABASE IF NOT EXISTS ${MYSQL_DB};

	CREATE USER IF NOT EXISTS ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO ${MYSQL_USER}@'%' WITH GRANT OPTION;

	CREATE USER IF NOT EXISTS ${MYSQL_ROOT_USER}@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	ALTER USER ${MYSQL_ROOT_USER}@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

	FLUSH PRIVILEGES;
EOF

# Run in the foreground
exec mariadbd --user=mysql --console