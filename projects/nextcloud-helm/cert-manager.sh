#!/bin/bash

set -e

# echo "Installing required CustomResourceDefinitions..."
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io
helm repo update
