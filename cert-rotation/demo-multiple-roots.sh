#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

BASE="./certs"
INTERMEDIATE_A="$BASE/intermediate-rootA"
INTERMEDIATE_A2="$BASE/intermediate-rootA2"
INTERMEDIATE_B="$BASE/intermediate-rootB"

. ./check-current-istio-certs.sh $INTERMEDIATE_A2

desc "Now we want to introduce a new Root CA! This can be tricky"
read -s
desc "We do this by introducing a new CA that contains both old and new Roots"
read -s
desc "Let's delete the existing secret"
run "kubectl delete -n istio-system secret cacerts"

desc "Let's create the istio same cacerts secert with a RootCA containing two roots"
run "cat ./certs/multiple-rootCA/root-cert.pem"
DIR=$INTERMEDIATE_A2
run "kubectl create secret generic cacerts -n istio-system --from-file=$DIR/ca-cert.pem --from-file=$DIR/ca-key.pem --from-file=./certs/multiple-rootCA/root-cert.pem --from-file=$DIR/cert-chain.pem"

desc "Now let's restart istiod to pick up this new cert"
run "kubectl delete po -n istio-system -l app=istiod "

SLEEP_POD=$(kubectl get po -n default | grep sleep | awk '{print $1}')
desc "It takes a few seconds....Lets see whether it was picked up"
run "kubectl get cm istio-ca-root-cert -n default -o jsonpath=\"{.data['root-cert\.pem']}\""
run "kubectl exec -it $SLEEP_POD -c istio-proxy -- cat /var/run/secrets/istio/root-cert.pem"


desc "Let's restart the httpbin service so it picks up new certs"
HTTPBIN_POD=$(kubectl get po -n default | grep httpbin | awk '{print $1}')
run "kubectl delete po $HTTPBIN_POD"

desc "Let's try call httpbin"
SLEEP_POD=$(kubectl get po -n default | grep sleep | awk '{print $1}')
run "kubectl exec -it $SLEEP_POD -c sleep -- curl httpbin:8000/headers"

desc "It all still works!"
read -s

