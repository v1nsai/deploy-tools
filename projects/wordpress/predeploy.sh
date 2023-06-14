#!/bin/bash

set -e

# Create base64 files
base64 -w 0 ~/.ssh/github_anonymous > ~/.ssh/github_anonymous.base64
base64 -w 0 projects/wordpress/install.sh > projects/wordpress/install.sh.base64