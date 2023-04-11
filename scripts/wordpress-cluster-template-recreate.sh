#!/bin/bash

echo "Deleting cluster and cluster template..."
openstack coe cluster delete wordpress
echo "Creating cluster template..."
while ! openstack coe cluster template create wordpress \
    --coe kubernetes \
    -f json \
    --image 'Fedora CoreOS (37.20230205.3.0-stable)' \
    --external-network External \
    --dns-nameserver 8.8.8.8 \
    --flavor alt.gp2.large \
    --master-flavor alt.gp2.large \
    --volume-driver cinder \
    --docker-storage-driver overlay \
    --docker-volume-size 20 \
    --labels="kube_dashboard_enabled=true,csi_snapshotter_tag=v4.0.0,kube_tag=v1.23.3-rancher1,cloud_provider_enabled=true,hyperkube_prefix=docker.io/rancher/,ingress_controller=octavia,master_lb_floating_ip_enabled=false" \
    --network-driver calico
    #     --master-lb-disabled \
    do 
        echo "Waiting for cluster to delete..."
        openstack coe cluster template delete wordpress 
        sleep 5
    done

echo "Creating cluster..."
openstack coe cluster create wordpress \
    --cluster-template wordpress \
    --master-count 1 \
    --node-count 1 \
    --floating-ip-disabled \
    --keypair techig-site


# openstack loadbalancer create --name wordpress-site --vip-subnet-id wordpress_subnet1
# openstack loadbalancer show wordpress-site
# openstack loadbalancer listener create --name listener1 --protocol HTTP --protocol-port 80 wordpress-site
# openstack loadbalancer pool create --name pool1 --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP
# openstack loadbalancer member create --subnet-id private-subnet --protocol-port 80 pool1
# openstack loadbalancer member create --subnet-id private-subnet --protocol-port 80 pool1

# Resource DELETE failed: Conflict: resources.network.resources.private_subnet: Unable to complete operation on subnet 1fab9fdc-1b8e-4b81-99d6-25bc0ba222b0: One or more ports have an IP allocation from this subnet. Neutron server returns request_ids: ['req-77f26d59-61c8-4c1c-9f2e-903925df757c']