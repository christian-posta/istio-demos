#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We've separated the ingress gateway install from the control plane!!"
run "cat ./resources/ingress-gateways.yaml"
run "kubectl -n istio-system get po"

desc "Let's use this file to install an ingress gateway decoupled from the control plane"

run "kubectl create ns istio-ingress"
run "istioctl install -y -n istio-ingress -f ./resources/ingress-gateways.yaml --revision 1-9-5"
run "kubectl -n istio-ingress get po -w"
run "kubectl -n istio-ingress get svc"

backtotop
desc "Let's expose our services on the gateway"
read -s

run "cat ./resources/web-api-ingress.yaml"
run "kubectl -n istio-ingress apply -f ./resources/web-api-ingress.yaml"

URL=$(istioctl-ip)
desc "Let's call our service through the ingress gateway"
run "kubectl exec -it deploy/sleep -n default -- curl -v -H 'Host: istioinaction.io' http://istio-ingressgateway.istio-ingress/"


desc "Press Enter to continue to JWT demo, or CTRL+C to end demo here"
read -s

backtotop
desc "One of the most common things to do at the edge is secure your traffic"
desc "For example, we can require JWT verification on requests coming in"
read -s

run "cat ./resources/request-auth.yaml"
run "kubectl apply -f ./resources/request-auth.yaml"

run "cat ./resources/authorization-policy.yaml"
run "kubectl apply -f ./resources/authorization-policy.yaml"

desc "Give it a few seconds to take effect (ENTER to cont)"
read -s

desc "Now try call the service through ingress gateway"
run "kubectl exec -it deploy/sleep -n default -- curl -v -H 'Host: istioinaction.io' http://istio-ingressgateway.istio-ingress/"

source ./token-export.sh
desc "It failed!"
desc "let's pass a valid token"

run "kubectl exec -it deploy/sleep -n default -- curl -v -H 'Host: istioinaction.io' http://istio-ingressgateway.istio-ingress/ -H \"Authorization: Bearer $TOKEN\""


#kubectl exec -it deploy/sleep -n default -- curl -v -H 'Host: istioinaction.io' http://istio-ingressgateway.istio-ingress/  -H "Authorization: Bearer $TOKEN"


