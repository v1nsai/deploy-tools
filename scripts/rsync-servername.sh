#!/bin/bash

set -e

source_filename=$1
destination_filename=$5
direction=$2
server_name=$3
network_name=$4

function show_usage {
  echo $(
    cat <<EOF
    Usage: $0 
      -s|--source-filename <source_filename> 
      -d|--destination-filename <destination_filename> 
      -r|--direction <direction> 
      -n|--server-name <server_name> 
      -w|--network-name <network_name>
EOF
  )
}

# # Parse command-line arguments
# while [[ $# -gt 0 ]]; do
#   case $1 in
#   -s | --source-filename)
#     source_filename=$2
#     shift
#     shift
#     ;;
#   -d | --destination-file)
#     destination_filename=$2
#     shift
#     shift
#     ;;
#   -r | --direction)
#     direction=$2
#     shift
#     shift
#     ;;
#   -n | --server-name)
#     server_name=$2
#     shift
#     shift
#     ;;
#   -w | --network-name)
#     network_name=$2
#     shift
#     shift
#     ;;
#   *)
#     echo "Invalid option: $1"
#     show_usage
#     exit 1
#     ;;
#   esac
# done

# # Check if all required args are provided
# if [[ -z $source_filename || -z $destination_filename || -z $direction || -z $server_name || -z $network_name ]]; then
#   echo "Missing required argument."
#   show_usage
#   exit 1
# fi

server_ip=$(openstack server show devbox -f json | jq '.addresses.'$network_name'[] | select(startswith("216"))' | sed 's/"//g')

if [ "$direction" = "to" ]; then
  # scp -r -i ~/.ssh/$server_name $source_filename localadmin@"$server_ip":$destination_filename
rsync -av --ignore-errors -e "ssh -i ~/.ssh/$server_name -l localadmin" "$source_filename" "$server_ip:$destination_filename"
elif [ "$direction" = "from" ]; then
  # scp -r -i ~/.ssh/$server_name localadmin@"$server_ip":$source_filename $destination_filename
  rsync -av --ignore-errors -e "ssh -i ~/.ssh/$server_name -l localadmin" "$server_ip:$source_filename" "$destination_filename"
fi
