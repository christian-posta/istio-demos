#!/bin/bash
# for gke
URL=$(k get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
echo "$URL"

while true
do curl -H "Host: istioinaction.io" $URL
sleep .4
done

