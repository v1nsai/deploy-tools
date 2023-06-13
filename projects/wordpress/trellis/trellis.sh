#!/bin/bash

set -e

cd projects/wordpress/trellis/$1
trellis init
trellis $2 $3

cd $(git rev-parse --show-toplevel)
