# ALTERNcloud Wordpress Deploy
Deploy a new Wordpress instance in seconds on ALTERNcloud

## Usage
Set the following environment variables when creating an instance:
```
DOMAIN="" # required, set to your domain name or set to "temporary" for a temporary domain name (coming soon after we work out an issue with our DNS provider)
SSL_PROVISIONER="" # optional, will default to letsencrypt or can be set to manual to provide your own certs
ADMIN_PASSWD="" # optional, will default to "Ch4ngeM3Qu1ck!"
```
The admin user is localadmin.

## Setting up SSL manually
* Set SSL_PROVISIONER="manual"
* ssl cert goes in /opt/wp-deploy/nginx/ssl/live/$DOMAIN/fullchain.pem
* ssl private key goes in /opt/wp-deploy/nginx/ssl/live/$DOMAIN/privkey.pem
