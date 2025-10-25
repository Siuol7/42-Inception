#Base image
FROM alpine:3.21.0

#Update package
#Install packages without cache
#Install bash -> run entrypoint script, install curl to download, install mariadb-client
#Install php 8.3 cli, php-fpm and php extension
#Install mbstring -> execute multibyte string(emoji,...), ssl cert, xml file executor, wp-cli.phar, session(login)
#Create system group www-data if not exist
RUN apk update && \
	apk add --no-cache \
		bash curl mariadb-client \
		php83 php83-fpm php83-mysqli php83-json php83-curl php83-dom \
		php83-mbstring php83-openssl php83-xml php83-phar php83-session && \
	addgroup -S www-data || true && \
	adduser -S -G www-data www-data || true && \
	mkdir -p /var/www/html && \
	chown -R www-data:www-data /var/www/html && \
	chmod -R 755 /var/www/html

#Set working dir (~cd)
WORKDIR /var/www/html

#Download wp-cli.phar with original name by curl tool and set permission executable
#WP-CLI -> set up wordpress by cmd line
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar

#Copy custom config instead of using alpine default config
COPY conf/www.conf /etc/php83/php-fpm.d/


COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh && \
	sed -i '/^memory_limit\s*=/c\memory_limit = 512M' /etc/php83/php.ini || \
	echo "memory_limit = 512M" >> /etc/php83/php.ini
	
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]