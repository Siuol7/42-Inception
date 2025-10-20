#!/bin/bash
set -e

cd /var/www/html

if [ ! -e .firstmount ]; then
    echo "First time setup..."
    
    if [ -f /run/secrets/wordpress_admin_password ]; then
        WP_ADMIN_PASSWORD="$(cat /run/secrets/wordpress_admin_password)"
    fi
    if [ -f /run/secrets/wordpress_user_password ]; then
        WP_USER_PASSWORD="$(cat /run/secrets/wordpress_user_password)"
    fi
    
    mariadb-admin ping --protocol=tcp --host=mariadb \
        -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --wait >/dev/null 2>&1
    
    if [ ! -f wp-config.php ]; then
        ./wp-cli.phar core download --allow-root || true
        ./wp-cli.phar config create --allow-root \
            --dbname="$MYSQL_DB" \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbhost="$MYSQL_HOST"
        ./wp-cli.phar core install --allow-root \
            --skip-email \
            --url="$WP_URL" \
            --title="$WP_TITLE" \
            --admin_user="$WP_ADMIN" \
            --admin_password="$WP_ADMIN_PASSWORD" \
            --admin_email="$WP_ADMIN_EMAIL"
        ./wp-cli.phar user create --allow-root \
            "$WP_USER" "$WP_USER_EMAIL" \
            --role="$WP_USER_ROLE" \
            --user_pass="$WP_USER_PASSWORD"
    fi
    
    chown -R www-data:www-data /var/www/html
    chmod -R 775 /var/www/html/wp-content
    
    touch .firstmount
fi

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
exec php-fpm$PHP_VERSION -F