#!/bin/bash

set -e

# Install
helm plugin install https://github.com/komodorio/helm-dashboard.git

# Update
# helm plugin update dashboard

# Start
helm dashboard