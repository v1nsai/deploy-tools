#!/bin/bash

source auth/alterncloud.env
ansible-playbook ../algo/main.yml -e "provider=openstack
                                server_name=algo
                                ondemand_cellular=false
                                ondemand_wifi=false
                                dns_adblocking=true
                                ssh_tunneling=true
                                store_pki=true"