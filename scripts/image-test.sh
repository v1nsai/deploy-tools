#!/bin/bash

set -e

REBUILD=false
ENV=auth/sandbox-openrpc.sh
NODESTROY=false
while [ $# -ne 0 ]
do
    arg="$1"
    case "$arg" in
        --rebuild)
            REBUILD=true
            ;;
        --dev)
            ENV=auth/dev-openrpc.sh
            NAME="--dev"
            ;;
        --test)
            ENV=auth/testing-openrpc.sh
            NAME="--test"
            ;;
        --stage)
            ENV=auth/stage-openrpc.sh
            NAME="--stage"
            ;;
        --prod)
            ENV=auth/production-openrpc.sh
            NAME="--prod"
            ;;
        --imagename*)
            IMAGENAME=`echo $1 | sed -e 's/^[^=]*=//g'`
            ;;
        --nodestroy)
            NODESTROY=true
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

if $DESTROY; then
    echo "Removing old instance..."
    scripts/destroy-terraform.sh $PROJECT
fi

if $REBUILD; then
    echo "Building new image..."
    scripts/packer-build.sh $PROJECT
fi

echo "Creating new instance..."
scripts/apply-terraform.sh $PROJECT

if [ ! -z "$IMAGENAME" ]; then
    PROJECT=$IMAGENAME
fi

echo "Switching to instance logs..."
scripts/watch-log.sh $PROJECT

echo "Connecting to instance..."
scripts/ssh-servername.sh $PROJECT $NAME
