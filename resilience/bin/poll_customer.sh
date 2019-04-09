#!/bin/bash

# for openshift
#URL="customer-tutorial.$(minishift ip).nip.io"

# for minikube
#URL=$(minikube ip):$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

# for gke
URL=$(k get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
echo "$URL"

while true
do curl -H "Host: resilience.customer.io" $URL
sleep .4
done

