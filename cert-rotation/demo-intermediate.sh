#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

BASE="./certs"
INTERMEDIATE_A="$BASE/intermediate-rootA"
INTERMEDIATE_A2="$BASE/intermediate-rootA2"
INTERMEDIATE_B="$BASE/intermediate-rootB"

. ./check-current-istio-certs.sh $INTERMEDIATE_A

desc "Now we want to introduce a new Intermediate CA with same root"
read -s
desc "We should first save the old cacerts"
read -s
desc "Let's delete the existing secret"
run "kubectl delete -n istio-system secret cacerts"

desc "Let's create the istio NEW cacerts secert"
desc "Check the certs if you like?"
read -s
DIR=$INTERMEDIATE_A2
run "kubectl create secret generic cacerts -n istio-system --from-file=$DIR/ca-cert.pem --from-file=$DIR/ca-key.pem --from-file=$DIR/root-cert.pem --from-file=$DIR/cert-chain.pem"

desc "Now let's restart istiod to pick up this new cert"
run "kubectl delete po -n istio-system -l app=istiod "

desc "Let's check proxy-status"
run "istioctl proxy-status"

desc "Let's restart the httpbin service so it picks up new certs"
HTTPBIN_POD=$(kubectl get po -n default | grep httpbin | awk '{print $1}')
run "kubectl delete po $HTTPBIN_POD"

desc "Let's try call httpbin"
SLEEP_POD=$(kubectl get po -n default | grep sleep | awk '{print $1}')
run "kubectl exec -it $SLEEP_POD -c sleep -- curl httpbin:8000/headers"
