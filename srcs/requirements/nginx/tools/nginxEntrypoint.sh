#!/bin/sh
set -e

# openssl -> open tool work with ssl , req-> request ssl certi, -x509 -> option selfsigned -> get certi  immediately
# -days 365 -> valid 365 days
# create new pair key , rsa algorithm,2048 bits
# nodes -> nginx read directly -> not require password
#

openssl req -x509 \ 
			-days 365 \
			-newkey rsa:2048 \
			-nodes \
			-keyout /etc/nginx/ssl/cert.key \
			-out /etc/nginx/ssl/cert.crt \
			-subj "/CN=$DOMAIN_NAME"

# Set file permissions -> key readable/writable only by owner (600)
chmod 600 /etc/nginx/ssl/cert.key
# Certificate readable by everyone (644)
chmod 644 /etc/nginx/ssl/cert.crt

# Run in the foreground: override the default config and prevent daemonizing
exec nginx -g "daemon off;"