#!/bin/bash

set -e

REBUILD=false
ENV=auth/sandbox-openrpc.sh
while [ $# -ne 0 ]
do
    arg="$1"
    case "$arg" in
        --rebuild)
            REBUILD=true
            ;;
        --sandbox | --dev)
            ENV=auth/sandbox-openrpc.sh
            ;;
        --production | --prod)
            ENV=auth/production-openrpc.sh
            ;;
        *)
            PROJECT=$arg
            ;;
    esac
    shift
done

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 [--rebuild] [--sandbox|--dev|--production|--prod] <project>"
    exit 1
elif [ -z "$ENV" ]; then
    echo "Usage: $0 [--rebuild] [--sandbox|--dev|--production|--prod] <project>"
    exit 1
elif [ ! -f "$ENV" ]; then
    echo "Environment file $ENV does not exist"
    exit 1
fi

source $ENV

if $REBUILD; then
    echo "Building new image..."
    scripts/packer-build.sh $PROJECT
fi

echo "Deleting and recreating new instance..."
scripts/destroy-terraform.sh $PROJECT
scripts/apply-terraform.sh $PROJECT

echo "Switching to instance logs..."
scripts/watch-log.sh $PROJECT

echo "Connecting to instance..."
scripts/ssh-servername.sh $PROJECT
