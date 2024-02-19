# TechIG Nextcloud Appliance for ALTERNcloud
Deploy a new Nextcloud instance in seconds on ALTERNcloud

## Features
* E2E secure communications with auto retrieved or generated SSL certificates
* Migration plugins pre-installed and activated
* Auto updating and secure configuration

## Usage
### SSL
Set the `URL` environment variable when deploying an instance from the `Nextcloud: automated` image. If this is not set at boot then a self-signed certificate and key will be generated and used.

Once you've updated your DNS records to point to the IP address of your instance, you can update the `URL` variable in `/etc/environment` and reboot. At next boot the system will get production certs from LetsEncrypt and your instance will securely use your domain name.

This can all be done with a single command after logging in with SSH or the console.  Replace "mydomain.com" with the domain you want to use with your instance
`echo 'URL=mydomain.com' | sudo tee -a /etc/environment && sudo reboot`

### Initial Setup
The Nextcloud AIO web console can be accessed at `YourPublicInstanceIP:8080`.  We recommend that instead of exposing this port to the internet, even temporarily, that users use an SSH tunnel to do this initial setup.  This can be done with the following command: `ssh -i path/to/keyfile ubuntu@<YourPublicInstanceIP> -L 8080:localhost:8080`.  Be sure to replace `<YourPublicInstanceIP>` with the public IP of your instance.  As long as you are logged into that session, you can visit `http://localhost:8080/` in your web browser and get to the Nextcloud AIO interface.  

Alternatively, opening port `8080` to the internet will (insecurely) simplify this process.

We recommend going through all of the options available on this page.  More detailed instructions can be found here

## Using custom SSL certs
By default the image will use letsencrypt to request SSL certs and keys. This can be changed by overwriting the following:
* SSL certs `/config/nginx/ssl/fullchain.pem`
* SSL private key `/config/nginx/ssl/privkey.pem`

## Building from source
Packer is used to build a new image and its build files are located at `projects/nextcloud/packer`.

Terraform is used to deploy a new instance and its build files are located at `projects/nextcloud/terraform`.
you
* Remove the `.template` suffix from from the 3 `*.template` files in the `terraform` and `packer` directories
* Fill in the variables with values from your Openstack `clouds.yml` or `openrc.sh`
* Build the image and deploy a new instance from it:
    * `scripts/image-test.sh nextcloud --rebuild`
* Only deploy a new instance from the most recently created nextcloud image:
    * `scripts/image-test.sh nextcloud`

# Domain when first logging into :8080
# skip docker for updating trusted_proxies
# not a simple way to self signed cert because nextcloud requires a domain to start