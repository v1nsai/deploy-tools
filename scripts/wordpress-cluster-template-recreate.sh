#!/bin/bash

openstack coe cluster delete wordpress-cluster
openstack coe cluster template delete wordpress-cluster
openstack coe cluster template create wordpress-cluster \
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
    --master-lb-enabled \
    --labels="kube_dashboard_enabled=True,csi_snapshotter_tag=v4.0.0,kube_tag=v1.23.3-rancher1,cloud_provider_enabled=True,hyperkube_prefix=docker.io/rancher/,ingress_controller=octavia,master_lb_floating_ip_enabled=False" \
    --network-driver calico
    # -f yaml \
    # --fixed-network private_network \
    # --fixed-subnet private_subnet1 \
    # --floating-ip-disabled \
    # --keypair techig-site \
    

openstack coe cluster create wordpress-cluster \
    --cluster-template wordpress-cluster \
    --master-count 1 \
    --node-count 1 \
    --floating-ip-disabled \
    --keypair techig-site
    # --fixed-network private_network \
    # --fixed-subnet private_subnet1

# this works but ignores disabling floating ip
# openstack coe cluster create kubernetes-v1.23.3-rancher1 \
#     --cluster-template kubernetes-v1.23.3-rancher1 \
#     --master-count 1 \
#     --node-count 1 \
#     --floating-ip-disabled \
#     --keypair techig-site