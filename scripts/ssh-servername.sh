#!/bin/bash

while [ $# -ne 0 ]
do
    arg="$1"
    case "$arg" in
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

source $ENV
openstack server ssh $PROJECT -- -l localadmin -i ~/.ssh/$PROJECT