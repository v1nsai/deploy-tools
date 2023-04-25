#!/bin/bash

git clone https://github.com/nextcloud/helm.git
cd helm
helm install nextcloud charts/templates/nextcloud

helm upgrade nextcloud ./nextcloud

# helm repo add nextcloud https://nextcloud.github.io/helm/
# helm repo update
# helm install nextcloud nextcloud/nextcloud --set nextcloud.password="jonk9ym.;lkj;lkj",nextcloud.host=0.0.0.0,service.type=LoadBalancer