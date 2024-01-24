# TechIG Deploy Tools
Scripts and templates and everything else needed to create and launch TechIG images on ALTERNcloud

# Usage
General flow is to deploy and provision an instance with Terraform + cloud-init + scripts.  Once it has been tested and fixed and has reached a stable point and is ready for release, the cloud-init and scripts are moved to Packer templates and an image is created.  This image is then tested using Terraform.

The folder hierarchy of the `projects/` folder is somewhat strict in order to allow using the scripts in the `scripts/` folder on multiple projects.  The structure needs to be similar to the following:

```
projects/
├── project1/
│   ├── terraform/
│   ├── packer/
│   └── install.sh
└── project2/
    ├── terraform/
    ├── packer/
    └── install.sh
```

You can then deploy an instance using the folder name from the `projects/` folder (ie project1)

## Deploy an instance
The `scripts/image-test.sh` script is a convenience script that runs several other scripts.  It does the following:
1. Builds image (if specified with `--rebuild`)
2. Runs `terraform destroy` on the project's `terraform/` folder
3. Runs `terraform apply` on the project's `terraform/` folder
4. Switches to the logs on the newly created instance
5. When the logs are manually exited with `ctrl+c` by the developer, it opens an SSH connection to the new instance

```
PROJECT_NAME="project1" # use the folder name from projects/ 

# Build the packer image, then launch an instance from that image on the dev/sandbox environment
scripts/image-test.sh $PROJECT_NAME --rebuild --dev

# Only perform the `terraform` deployment without rebuilding the image first
scripts/image-test.sh $PROJECT_NAME --dev
```