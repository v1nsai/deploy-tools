#!/bin/bash

set -e

# Access the login page
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl proxy &
open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# Get the login token
kubectl -n kubernetes-dashboard create serviceaccount admin
kubectl -n kubernetes-dashboard create clusterrolebinding admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin
kubectl -n kubernetes-dashboard create token admin
kubectl -n kubernetes-dashboard create secret generic admin --from-literal=token=$(kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa admin -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode)
