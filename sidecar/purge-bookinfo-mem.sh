#!/bin/bash

BOOKINFO_PODS=$(kubectl get pod -n default | grep -i running | awk '{ print $1 }')
for pod in $BOOKINFO_PODS; do
    k exec $pod -c istio-proxy -- /sbin/killall5 
done

