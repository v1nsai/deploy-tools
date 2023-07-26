#!/bin/bash

set -e

# Vars
CERT_FILENAME="$1"
KEY_FILENAME="$2"
DAYS=365
COUNTRY="US"
STATE="California"
CITY="San Francisco"
ORGANIZATION="My Company"
ORGANIZATION_UNIT="IT"
EMAIL="admin@mydomain.com"

# Create directories if necessary
mkdir -p $(dirname "$CERT_FILENAME")
mkdir -p $(dirname "$KEY_FILENAME")

# Generate key
openssl genrsa -out "$KEY_FILENAME" 2048

# Generate cert
openssl req -new -key "$KEY_FILENAME" -out "$CERT_FILENAME" -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$DOMAIN/emailAddress=$EMAIL"
openssl x509 -req -days "$DAYS" -in "$CERT_FILENAME" -signkey "$KEY_FILENAME" -out "$CERT_FILENAME"

echo "Successfully generated $CERT_FILENAME and $KEY_FILENAME."
