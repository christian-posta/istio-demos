#!/bin/bash
#kubectl create ns istio-system
#kubectl apply -f istio-sds-install-v1.3.3.yaml
#kubectl label ns default istio-injection=enabled
kubectl create ns hello-v1
kubectl create ns hello-v2
kubectl label ns hello-v1 istio-injection=enabled
kubectl label ns hello-v2 istio-injection=enabled
kubectl apply -f resources/helloworld-deployment.yaml
