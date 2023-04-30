#!/bin/bash

set -e

echo "Deleting cluster and jump server..."
openstack stack delete -y jump-server | true;
openstack coe cluster delete wordpress | true
echo "Deleting cluster template..."
while openstack coe cluster template delete wordpress | grep 'HTTP 400' > /dev/null
do 
    echo "Waiting for cluster created from template to delete..."
    openstack coe cluster delete wordpress | true
    sleep 5
done
echo "Creating cluster template..."
openstack coe cluster template create wordpress \
    --coe kubernetes \
    -f json \
    --image 'Fedora CoreOS (37.20230205.3.0-stable)' \
    --external-network External \
    --dns-nameserver 8.8.8.8 \
    --flavor alt.gp2.large \
    --master-flavor alt.gp2.large \
    --volume-driver cinder \
    --floating-ip-disabled \
    --labels="kube_dashboard_enabled=true,\
        cinder_csi_enabled=true,\
        kube_tag=v1.23.3-rancher1,\
        cloud_provider_enabled=true,\
        hyperkube_prefix=docker.io/rancher/,\
        csi_snapshotter_tag=v4.0.0,\
        ingress_controller=octavia"
    # --docker-volume-size 20 \
    # --network-driver flannel \
    # --labels="ingress_controller=octavia,master_lb_floating_ip_enabled=false"\

echo "Creating cluster..."
openstack coe cluster create wordpress \
    --cluster-template wordpress \
    --master-count 1 \
    --node-count 1 \
    --keypair techig-site \
    --floating-ip-disabled

echo "Starting jump-server creation..."
wordpress_subnet_id=
wordpress_network_id=
while [ ! ${#wordpress_subnet_id} -eq 36 ] && [ ! ${#wordpress_network_id} -eq 36 ]
do
    echo "Waiting for 'wordpress' network to be created..."
    wordpress_subnet_id=$(openstack network list --name wordpress -f json | jq --raw-output '.[0].Subnets[0]')
    wordpress_network_id=$(openstack network list --name wordpress -f json | jq --raw-output '.[0].ID')
    sleep 5
done
echo "Updating jump-server yaml..."
filter='.parameters.private_subnet_id.default = '
filter+=\"$wordpress_subnet_id\"
yq e -i "$filter" templates/jump-server.yaml
filter='.parameters.private_network_id.default = '
filter+=\"$wordpress_network_id\"
yq e -i $filter templates/jump-server.yaml
echo $wordpress_subnet_id

scripts/recreate-stack.sh templates/jump-server.yaml jump-server

echo "Finished!"
    # --docker-storage-driver overlay \