#!/bin/bash

set -e

git clone -n --depth=1 --filter=tree:0 \
  git@github.com:v1nsai/deploy-tools.git $2
cd ${2:=deploy-tools}
git sparse-checkout set --no-cone $1
git checkout
