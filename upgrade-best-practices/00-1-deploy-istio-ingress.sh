#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We have Istio deployed with no ingress gateway"
run "kubectl get po -n istio-system"

desc "We have our workloads deployed in istioinaction namespace"
run "kubectl get po -n istioinaction"

desc "Lets take a look at how to do Gateway injection"
desc "We start with a gateway deployment that doesn't have much filled out"
desc "Note the template annotation"
run "cat scenario-1-ing-gw/ingress-gw.yaml"

desc "Now if we apply this gateway, we should see it deployed"
run "kubectl create ns istio-ingress"
run "kubectl label ns istio-ingress istio.io/rev=1-9-5"
run "istioctl install -f scenario-1-ing-gw/ingress-gw.yaml --revision=1-9-5"

desc "Now if we configure the gateway, we should be able to call it"
run "cat scenario-1-ing-gw/web-api-gw.yaml"
run "kubectl apply -f scenario-1-ing-gw/web-api-gw.yaml"

desc "Let's call into the mesh via the gateway"

# kubectl -n default exec -it deploy/sleep -- curl -H "Host: istioinaction.io" http://ingressgateway.istio-ingress/
run "kubectl -n default exec -it deploy/sleep -- curl -H \"Host: istioinaction.io\" http://ingressgateway.istio-ingress/"