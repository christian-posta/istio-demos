#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We have services"
run "kubectl -n istioinaction get po"

desc "Install Istio"
run "istioctl install -y"

desc "Verify control plane installed correctly"
run "kubectl get po -n istio-system"

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

desc "Give it a few seconds to take effect (ENTER to cont)"
read -s

desc "Now try call the service through ingress gateway"
run "curl -v -H 'Host: istioinaction.io' http://$URL/"

source ./token-export.sh
desc "It failed!"
desc "let's pass a valid token"

run "curl -v -H 'Host: istioinaction.io' http://$URL/ -H \"Authorization: Bearer $TOKEN\""
