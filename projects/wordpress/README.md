# ALTERNcloud Wordpress Deploy
Deploy a new Wordpress instance in seconds on ALTERNcloud

## Usage
Set the following environment variables when creating an instance:
```
DOMAIN="" # required, set to your domain name or "temporary" for a temporary domain name (coming soon)
SSL_PROVISIONER="" # optional, will default to letsencrypt
ADMIN_PASSWD="" # optional, will default to "Ch4ngeM3Qu1ck!"
```

The admin user is localadmin and the default password is "Ch4ngeM3Qu1ck!"