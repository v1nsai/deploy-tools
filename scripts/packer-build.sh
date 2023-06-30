#!/bin/bash

set -e
export PACKER_LOG=1
export PACKER_LOG_PATH=packer.log

rm -rf output-*
packer init -upgrade projects/$1/packer
packer fmt projects/$1/packer
packer validate projects/$1/packer
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" | packer build -debug projects/$1/packer