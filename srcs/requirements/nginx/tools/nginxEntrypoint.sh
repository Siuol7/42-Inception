#!/bin/sh
set -e

# openssl req: create a SSL (Secure Sockets Layer certificate)
#	-x509: create X.509 certificate.
#	-days 365: valid for 365 days.
#	-newkey rsa:2048: generate a new 2048-bit RSA key.
#	-nodes: do not encrypt the private key.
#	-keyout: output file for private key.
#	-out: output file for certificate.
#	-subj: set the certificate subject (Common Name) from $DOMAIN_NAME.
openssl req -x509 \
			-days 365 \
			-newkey rsa:2048 \
			-nodes \
			-keyout /etc/nginx/ssl/cert.key \
			-out /etc/nginx/ssl/cert.crt \
			-subj "/CN=$DOMAIN_NAME"

# Set file permissions
# Private key readable/writable only by owner (600)
chmod 600 /etc/nginx/ssl/cert.key
# Certificate readable by everyone (644)
chmod 644 /etc/nginx/ssl/cert.crt

# Run in the foreground: override the default config and prevent daemonizing
exec nginx -g "daemon off;"