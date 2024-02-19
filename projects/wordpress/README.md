# TechIG Wordpress Appliance for ALTERNcloud
Deploy a new Wordpress instance in seconds on ALTERNcloud

## Features
* E2E secure communications with auto retrieved or generated SSL certificates
* Migration plugins pre-installed and activated
* Auto updating and secure configuration

## Usage
Set the `URL` environment variable when deploying an instance from the `WordPress: automated` image. If this is not set at boot then a self-signed certificate and key will be generated and used.

Once you've updated your DNS records to point to the IP address of your instance, you can update the `URL` variable in `/etc/environment` and reboot. At next boot the system will get production certs from LetsEncrypt and your instance will securely use your domain name.

This can all be done with a single command after logging in with SSH or the console.  Replace "mydomain.com" with the domain you want to use with your instance
`echo 'URL=mydomain.com' | sudo tee -a /etc/environment && sudo reboot`

## Using custom SSL certs
By default the image will use letsencrypt to request SSL certs and keys. This can be changed by overwriting the following:
* SSL certs `/config/nginx/ssl/fullchain.pem`
* SSL private key `/config/nginx/ssl/privkey.pem`

## Building from source
Packer is used to build a new image and its build files are located at `projects/wordpress/packer`.

Terraform is used to deploy a new instance and its build files are located at `projects/wordpress/terraform`.
you
* Remove the `.template` suffix from from the 3 `*.template` files in the `terraform` and `packer` directories
* Fill in the variables with values from your Openstack `clouds.yml` or `openrc.sh`
* Build the image and deploy a new instance from it:
    * `scripts/image-test.sh wordpress --rebuild`
* Only deploy a new instance from the most recently created Wordpress image:
    * `scripts/image-test.sh wordpress`
