#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


SOURCE_DIR=$PWD
kubectl create ns istio-demo
kubectl label namespace istio-demo istio-injection=enabled

sleep 3s

kubectl apply -f $(relative kube/recommendation-v1-deployment.yml) -n istio-demo
kubectl apply -f $(relative kube/recommendation-service.yml) -n istio-demo

kubectl apply -f $(relative kube/preference-deployment.yml) -n istio-demo
kubectl apply -f $(relative kube/preference-service.yml) -n istio-demo

kubectl apply -f $(relative kube/customer-deployment.yml) -n istio-demo
kubectl apply -f $(relative kube/customer-service.yml) -n istio-demo

kubectl apply -f $(relative istio/customer-gateway.yaml) -n istio-demo
kubectl apply -f $(relative istio/customer-virtual-service.yaml) -n istio-demo
