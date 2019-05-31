#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

# grafana: http://localhost:3000
# kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 


# jaeger: http://localhost:16686
# kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686



SOURCE_DIR=$PWD

kubectl apply -f <(istioctl kube-inject -f $(relative kube/recommendation-v1-deployment.yml))
kubectl apply -f $(relative kube/recommendation-service.yml)

kubectl apply -f <(istioctl kube-inject -f $(relative kube/preference-deployment.yml))
kubectl apply -f $(relative kube/preference-service.yml)

kubectl apply -f <(istioctl kube-inject -f $(relative kube/customer-deployment.yml))
kubectl apply -f $(relative kube/customer-service.yml)

kubectl apply -f $(relative istio/customer-gateway.yaml)
kubectl apply -f $(relative istio/customer-virtual-service.yaml)