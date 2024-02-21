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
            NAME="--dev"
            ;;
        --production | --prod)
            ENV=auth/production-openrpc.sh
            NAME="--prod"
            ;;
        --imagename*)
            IMAGENAME=`echo $1 | sed -e 's/^[^=]*=//g'`
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

echo "Removing old instance..."
scripts/destroy-terraform.sh $PROJECT

if $REBUILD; then
    echo "Building new image..."
    scripts/packer-build.sh $PROJECT $IMAGENAME
fi

echo "Creating new instance..."
scripts/apply-terraform.sh $PROJECT

echo "Switching to instance logs..."
scripts/watch-log.sh $PROJECT $IMAGENAME

echo "Connecting to instance..."
scripts/ssh-servername.sh $PROJECT $IMAGENAME
