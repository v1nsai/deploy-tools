#!/bin/bash

set -e

kompose convert -f projects/$1/docker/docker-compose.yml -o projects/$1/kubernetes