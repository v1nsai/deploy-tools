[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) ![OpenStack](https://img.shields.io/badge/Openstack-%23f01742.svg?style=for-the-badge&logo=openstack&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) 

# OpenStack Deploy Tools
Scripts and templates I've been using to deploy resources on OpenStack powered providers

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

You can then deploy an instance using the folder name from the `projects/` folder (ie project1), referred to as PROJECTNAME here.

## Authentication
### Get `openrc.sh`
You'll need to get the `openrc.sh` file from openstack first to deploy anything.  Log into the client area, select your product (EZ Cloud, HPC or VPC) and select "API" from the column on the left.  Copy the contents into `auth/ENV-openrc.sh`, replacing `ENV` with the short name of the environment you're working with.  The currently supported names are "dev", "test", "stage" and "prod".  So for example if you're working in "dev", you would go retrieve the `openrc.sh` and put it in `auth/dev-openrc.sh`.

### Authenticating OpenStack CLI Client
Once you have copy and pasted the `openrc.sh` file, you have to source it first using the command `source auth/openrc.sh`.  You should now be able to run `openstack image list` to get a list of images available to your account.

### Authenticating Terraform
To run any of the deploy scripts, you must first authenticate terraform. Simply copy the `openstack.auto.tfvars.template` file into `projects/PROJECTNAME/terraform/` folder, remove `.template` from the file name and fill in the corresponding info from the `openrc.sh` file explained in the comments on each line.

## Deploying Projects
The `scripts/image-test.sh` script is a convenience script that runs several other scripts.  It does the following:
1. Builds image (if specified with `--rebuild`)
2. Runs `terraform destroy` on the project's `terraform/` folder
3. Runs `terraform apply` on the project's `terraform/` folder
4. Switches to the logs on the newly created instance
5. When the logs are manually exited with `ctrl+c` by the developer, it opens an SSH connection to the new instance

### Available flags
* `--nodestroy`
* `--rebuild`
* `--dev | --test | --stage | --prod`

### Deploy a project in dev
`scripts/image-test.sh PROJECTNAME --dev`

### Deploy a project in prod after rebuilding custom image
`scripts/image-test.sh PROJECTNAME --prod --rebuild`

### Deploy a project in dev without destroying first
`scripts/image-test.sh PROJECTNAME --dev --nodestroy`
