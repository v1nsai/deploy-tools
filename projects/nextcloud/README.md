# Nextcloud

Although there are a few different nextcloud projects in the repo, this is the main one.  It uses the All-In-One (AIO) Docker image to deploy a single instance.  

Copy the `projects/nextcloud/terraform/nextcloud.auto.tfvars.template` file to `projects/nextcloud/terraform/nextcloud.auto.tfvars` and fill in the variables with your info.  It’s ok to skip the `url` variable if you just want to test with a self signed cert.

This project can be deployed with
`scripts/image-test.sh nextcloud –dev`

Rebuild the image before deploying.  Make sure that `projects/nextcloud/terraform/instance.tf` is configured to use the image name from `projects/nextcloud/packer/image.pkr.hcl` before proceeding:
`scripts/image-test.sh nextcloud –dev –rebuild`

After you are able to log into the instance with SSH, you’ll need to create a tunnel to port 8080 to access the AIO interface.  This is more complex, but more secure than opening the port to the internet.  Your SSH command will look something like this: `ssh localadmin@INSTANCEIPADDRESS  -i path/to/ssh/key -L 8080:localhost:8080`.  Then go to `localhost:8080` in your web browser.  I highly recommend reading all of these instructions before continuing.  Once you’ve added in the hostname, you’ll be able to start the containers
