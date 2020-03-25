#!/bin/bash
# for gke
URL=$(k get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

curl -v $URL -H "Host: istioinaction.io"