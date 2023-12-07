#!/bin/bash

set -e

helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install nextcloud-helm nextcloud/nextcloud

export APP_HOST=kubernetes.techig.com
export APP_PASSWORD=$(kubectl get secret --namespace default nextcloud-helm -o jsonpath="{.data.nextcloud-password}" | base64 --decode)

helm upgrade nextcloud-helm nextcloud/nextcloud \
    --set nextcloud.password=$APP_PASSWORD \
    --set nextcloud.host=$APP_HOST \
    --set service.type=LoadBalancer 
    # --set service.loadBalancerIP="216.87.32.125"
    # --set mariadb.enabled=true
    # --set externalDatabase.user=nextcloud \
    # --set externalDatabase.database=nextcloud \
    # --set externalDatabase.host=YOUR_EXTERNAL_DATABASE_HOST