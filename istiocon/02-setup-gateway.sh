#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We've separated the ingress gateway install from the control plane!!"
run "cat ./resources/ingress-gateways.yaml"
run "kubectl -n istio-system get po"

desc "Let's use this file to install an ingress gateway decoupled from the control plane"
run "istioctl install -n istio-system -f ./resources/ingress-gateways.yaml --revision 1-8-3"
run "kubectl -n istio-system get po -w"
run "kubectl -n istio-system get svc"

backtotop
desc "Let's expose our services on the gateway"
read -s

run "cat ./resources/web-api-ingress.yaml"
run "kubectl -n istioinaction apply -f ./resources/web-api-ingress.yaml"

URL=$(istioctl-ip)
desc "Let's call our service through the ingress gateway"
run "curl -v -H 'Host: istioinaction.io' http://$URL/"

backtotop
desc "One of the most common things to do at the edge is secure your traffic"
desc "For example, we can require JWT verification on requests coming in"
read -s

run "cat ./resources/request-auth.yaml"
run "kubectl apply -f ./resources/request-auth.yaml"

run "cat ./resources/authorization-policy.yaml"
run "kubectl apply -f ./resources/authorization-policy.yaml"

desc "Note! Lawrence's deep dive on Authorization Policies!"
read -s

desc "Give it a few seconds to take effect (ENTER to cont)"
read -s

desc "Now try call the service through ingress gateway"
run "curl -v -H 'Host: istioinaction.io' http://$URL/"

source ./token-export.sh
desc "It failed!"
desc "let's pass a valid token"

run "curl -v -H 'Host: istioinaction.io' http://$URL/ -H \"Authorization: Bearer $TOKEN\""






#curl -i -H "Host: istioinaction.io" -H "Origin: http://istio.io" -H "foo: bar" http://$(istioctl-ip)  -H "Authorization: Bearer $TOKEN"


