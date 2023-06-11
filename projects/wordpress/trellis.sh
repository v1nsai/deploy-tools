#!/bin/bash

cd projects/wordpress/$1
trellis $2 $3
cd $(git rev-parse --show-toplevel)