#!/bin/bash


# for v1alpha3
kubectl delete virtualservices.networking.istio.io  recommendation -n istio-demo
kubectl delete virtualservices.networking.istio.io  preference -n istio-demo
kubectl delete destinationrules.networking.istio.io  --all -n istio-demo