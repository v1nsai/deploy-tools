#!/bin/bash

source auth/aiac.env
source auth/alterncloud.env
set -e

# Clone repo if necessary, remove generated configs and copy server configs
# git clone https://github.com/trailofbits/algo.git ../algo
cp -f projects/algo/config.cfg ../algo/config.cfg
cp -f projects/algo/requirements.txt ../algo/requirements.txt
rm -rf projects/algo/configs || true

# Configure environment, openstacksdk needs to be manually downgraded which requires python < 3.11, 3.9 confirmed working
python3 -m pip install --user --upgrade virtualenv
python3 -m virtualenv --python="$(command -v python3)" ../algo/env &&
  source ../algo/.env/bin/activate &&
  python3 -m pip install -U pip virtualenv &&
  python3 -m pip install -r projects/algo/requirements.txt

# Add users
../algo/algo update-users

# Cleanup
deactivate
cp -rf ../algo/configs/ projects/algo/configs/