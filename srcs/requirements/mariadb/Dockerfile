#Alpine lighter, less package -> faster, apk faster > apt
FROM alpine:3.21.0

RUN apk update && \
	apk add --no-cache mariadb mariadb-client && \
	mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql && \
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

COPY conf/mariadb.cnf /etc/my.cnf.d/
COPY tools/mariaEntrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariaEntrypoint.sh"] 