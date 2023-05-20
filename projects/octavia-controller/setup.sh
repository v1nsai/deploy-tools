#!/bin/bash

set -e
source auth/alterncloud.env

kubectl -f projects/octavia-controller/manifest.yaml delete || true
envsubst < projects/octavia-controller/manifest.yaml | kubectl apply -f -