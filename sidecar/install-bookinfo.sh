#!/bin/bash

kubectl label namespace default istio-injection=enabled
pushd /Users/ceposta/dev/istio/latest
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml 
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml 
popd
