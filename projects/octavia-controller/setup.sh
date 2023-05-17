#!/bin/bash

set -e
source auth/alterncloud.env

kubectl delete serviceaccount/octavia-ingress-controller clusterrolebinding.rbac.authorization.k8s.io/octavia-ingress-controller configmap/octavia-ingress-controller-config statefulset.apps/octavia-ingress-controller -n kube-system
envsubst < octavia-controller/manifest.yaml | kubectl apply -f -