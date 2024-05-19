#!/bin/bash

# Set error handling and logging
set -e

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

terraform -chdir=projects/$PROJECT/terraform plan