#!/bin/bash

echo "Setting up python..."
apt install -y python3 python3-pip
ln -s /usr/bin/python3 /usr/bin/python

echo "Installing python-openstackclient..."
python -m pip install python-openstackclient python-magnumclient python-heatclient