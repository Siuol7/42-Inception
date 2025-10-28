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

# Copy our custom config -> replace alpine default config
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/http.d/default.conf

#Copy script to script dir for container 
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

#notify this container use HTTPS port
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginxEntrypoint.sh"]