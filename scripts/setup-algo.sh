#!/bin/bash

export STORE_PKI=true
export DNS_ADBLOCKING=true
export ENDPOINT=$(curl ifconfig.me)
export USERS="drew-macbook,drew-iphone,james-iphone"

echo "Setting up algo..."
curl -s https://raw.githubusercontent.com/trailofbits/algo/master/install.sh | sudo -E bash -x