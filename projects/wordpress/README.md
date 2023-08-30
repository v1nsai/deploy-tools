# ALTERNcloud Wordpress Deploy
Deploy a new Wordpress instance in seconds on ALTERNcloud

## Usage
Set the following environment variables when creating an instance:
```
DOMAIN="" # required, set to your domain name or set to "temporary" for a temporary domain name (coming soon after we work out an issue with our DNS provider)
```

## Setting up SSL manually
* ssl cert goes in /opt/wp-deploy/nginx/ssl/live/$DOMAIN/fullchain.pem
* ssl private key goes in /opt/wp-deploy/nginx/ssl/live/$DOMAIN/privkey.pem
