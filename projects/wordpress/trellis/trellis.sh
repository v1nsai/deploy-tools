#!/bin/bash

set -e

cd projects/wordpress/trellis/doctor-ew.com
trellis init
trellis provision staging

cd $(git rev-parse --show-toplevel)