#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

URL=$(k get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

desc "In this demo, we'll explore using Istio to require jwt validation"

desc "Let's try calling out service"
run "curl -H \"Host: istioinaction.io\" $URL"

desc "Istio uses RequestAuthentication policies for end-user identity and jwt validation"
run "cat resources/istio/istioinaction-requestauth.yaml"
run "kubectl apply -f resources/istio/istioinaction-requestauth.yaml"


desc "May have to wait a moment for the config to sycn"
read -s

desc "now let's try call our service"
run "curl -H \"Host: istioinaction.io\" $URL"


desc "We could call it with a valid JWT"
run "cat resources/jwt/token-iss-soloio.txt"


TOKEN=$(cat resources/jwt/token-iss-soloio.jwt)
run "curl -H \"Host: istioinaction.io\" $URL -H \"Authorization: Bearer $TOKEN\""
