#!/bin/bash

# Define the filename for the certificate and private key
CERT_FILE="my-self-signed-cert.pem"
KEY_FILE="my-private-key.pem"

# Generate the private key
openssl genpkey -algorithm RSA -out $KEY_FILE

# Generate the certificate signing request (CSR)
openssl req -new -key $KEY_FILE -out ${CERT_FILE}.csr

# Generate the self-signed certificate
openssl x509 -req -days 365 -in ${CERT_FILE}.csr -signkey $KEY_FILE -out $CERT_FILE

# Clean up the CSR file
rm ${CERT_FILE}.csr
