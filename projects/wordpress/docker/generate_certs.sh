#!/bin/bash

ORGANIZATION="Your Organization"
COUNTRY="US"
STATE="California"
CITY="San Francisco"
EMAIL="admin@$DOMAIN"
VALIDITY_DAYS=365
CERTIFICATE_FILE="$1"
PRIVATE_KEY_FILE="$2"

# Generate the self-signed certificate and private key
openssl req -x509 -nodes -days "$VALIDITY_DAYS" \
  -newkey rsa:2048 -keyout "$PRIVATE_KEY_FILE" -out "$CERTIFICATE_FILE" \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/CN=$DOMAIN/emailAddress=$EMAIL"

echo "Self-signed certificate and key generated successfully:"
echo "Certificate file: $CERTIFICATE_FILE"
echo "Private key file: $PRIVATE_KEY_FILE"
