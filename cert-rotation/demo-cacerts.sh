#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

. ./check-current-istio-certs.sh
backtotop
desc "Let's check that we can connect to httpbin service"
read -s

SLEEP_POD=$(kubectl get po -n default | grep sleep | awk '{print $1}')
run "kubectl exec -it $SLEEP_POD -c sleep -- curl -v httpbin:8000/headers"

desc "Let's see what certificate httbin"
SLEEP_POD=$(kubectl get po -n default | grep -i running | grep sleep | awk '{print $1}')
run "kubectl exec -it $SLEEP_POD -c istio-proxy -- openssl s_client -showcerts -connect httpbin:8000"

backtotop
desc "Lets update the root to our own CA"
read -s

desc "Let's create the istio cacerts secert that Istio will load on startup"
desc "Check the certs if you like?"
read -s
DIR=$INTERMEDIATE_A
run "kubectl create secret generic cacerts -n istio-system --from-file=$DIR/ca-cert.pem --from-file=$DIR/ca-key.pem --from-file=$DIR/root-cert.pem --from-file=$DIR/cert-chain.pem"

desc "Now let's restart istiod to pick up this new cert"
run "kubectl delete po -n istio-system -l app=istiod "

desc "Let's check the logs to make sure our cacert got picked up"
ISTIOD_POD=$(kubectl get po -n istio-system | grep Running | grep istiod | awk '{print $1}')
run "kubectl logs  $ISTIOD_POD -n istio-system | sed -n '/JWT policy is/,/validationServer/p'"

desc "Unfortunatley, changing the root certificate will lead to proxy not connecting"
run "istioctl proxy-status"

backtotop
desc "Let's see what happens with the connections between pods using mTLS"
read -s

desc "Let's restart the httpbin service so it picks up new certs"
HTTPBIN_POD=$(kubectl get po -n default  | grep -i running | grep httpbin | awk '{print $1}')
run "kubectl delete po $HTTPBIN_POD"

desc "Let's try call it again"
#echo "Maybe we should enable logs for the sleep pod?"
run "istioctl proxy-config log $SLEEP_POD --level connection:debug,conn_handler:debug > /dev/null"
desc "check sleep logs"
read -s
run "kubectl exec -it $SLEEP_POD -c sleep -- curl httpbin:8000/headers"

desc "So let's restart the sleep pod"
run "kubectl delete po $SLEEP_POD"

desc "Trying one more time!"
SLEEP_POD=$(kubectl get po -n default | grep -i running | grep sleep | awk '{print $1}')
run "kubectl exec -it $SLEEP_POD -c sleep -- curl httpbin:8000/headers"