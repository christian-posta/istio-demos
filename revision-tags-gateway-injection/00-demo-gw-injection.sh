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
run "cat resources/istio-ingress-deployment.yaml | head -n 25"

desc "Now if we apply this gateway, we should see it deployed"
run "kubectl apply -f resources/istio-ingress-deployment.yaml"
run "kubectl get po -n istioinaction -w"

desc "Now if we configure the gateway, we should be able to call it"
run "cat resources/web-api-gw.yaml"
run "kubectl apply -f resources/web-api-gw.yaml"

desc "Let's call into the mesh via the gateway"
# kubectl -n default exec -it deploy/sleep -- curl -H "Host: istioinaction.io" http://istioinaction-gw.istioinaction/
run "kubectl -n default exec -it deploy/sleep -- curl -H \"Host: istioinaction.io\" http://istioinaction-gw.istioinaction/"

