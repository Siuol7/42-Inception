#!/bin/bash
set -e

cd /var/www/html

#Check if it is set up alr -> by checking flag file .firstmount
if [ ! -e .firstmount ]; then
    echo "First time setup..."
    
    if [ -f /run/secrets/wordpress_admin_password ]; then
        WP_ADMIN_PASSWORD="$(cat /run/secrets/wordpress_admin_password)"
    fi
    if [ -f /run/secrets/wordpress_user_password ]; then
        WP_USER_PASSWORD="$(cat /run/secrets/wordpress_user_password)"
    fi
    
    #Check if mariadb alive -> wait until mariadb ready 
    #Connect to mariadb by tcp and hide all msgs and errors
    mariadb-admin ping --protocol=tcp --host=mariadb \
        -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --wait >/dev/null 2>&1
    
    #If wp-config.php exists -> Wordpress installed
    if [ ! -f wp-config.php ]; then

        #using wp-cli tool to download core files -> always return true
        ./wp-cli.phar core download --allow-root || true

        #create config file -> wordpress knows where to get database
        ./wp-cli.phar config create --allow-root \
            --dbname="$MYSQL_DATABASE" \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbhost="$MYSQL_HOST"

        #Install (create tables + admin user in database)
        ./wp-cli.phar core install --allow-root \
            --skip-email \
            --url="$WP_URL" \
            --title="$WP_TITLE" \
            --admin_user="$WP_ADMIN" \
            --admin_password="$WP_ADMIN_PASSWORD" \
            --admin_email="$WP_ADMIN_EMAIL"
        
        #Create a second user
        ./wp-cli.phar user create --allow-root \
            "$WP_USER" "$WP_USER_EMAIL" \
            --role="$WP_USER_ROLE" \
            --user_pass="$WP_USER_PASSWORD"
    fi
    
    #change owners of all files in html to www-data
    chown -R www-data:www-data /var/www/html

    #set permission
    chmod -R 775 /var/www/html/wp-content
    
    touch .firstmount
fi

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
exec php-fpm$PHP_VERSION -F