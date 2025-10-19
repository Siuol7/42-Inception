#Base image
FROM alpine:3.21.0

#Run multi commands
#1. Update apk
#2. Install Nginx, gettext(envsubst), openssl(SSL cert) -> not save in cache -> image lighter
#3. Make dir for ssl cert <- entrypoint.sh create ssl and put in 
#4. Create new user without password(-d), not create home dir, userID 82(nginx convention), deny login, username -> use to run process
RUN apk update && \
    apk add --no-cache nginx gettext openssl && \
    mkdir -p /etc/nginx/ssl && \
    adduser -D -H -u 82 -s /sbin/nologin www-data

# Copy main config (có user www-data;)
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy server blocks
COPY conf/default.conf /etc/nginx/http.d/default.conf

COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]