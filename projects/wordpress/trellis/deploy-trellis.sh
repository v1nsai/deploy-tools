#!/bin/bash

set -e

project_directory=projects/wordpress
brew install roots/tap/trellis-cli
mkdir -p $project_directory/trellis
cd $project_directory/trellis
trellis init
trellis new $project_directory/doctor-ew.com
trellis provision ENV
trellis deploy ENV