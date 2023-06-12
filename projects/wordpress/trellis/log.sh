#!/bin/bash

cd projects/wordpress/trellis/doctor-ew.com
trellis logs staging
cd $(git rev-parse --show-toplevel)