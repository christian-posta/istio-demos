#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Let's create a letsencrypt Certificate using certmanager"
run "cat $(relative resources/cert-hello-v1.yaml)"
run "kubectl apply -f $(relative resources/cert-hello-v1.yaml)"
run "kubectl get secret -n istio-system hello-v1-cert"

desc "We need to configure the ingressgateway to use the cert from SDS"
run "cat $(relative resources/v1-https.yaml)"
run "kubectl apply -f $(relative resources/v1-https.yaml)"

ING_GATEWAY_IP=$(kubectl  get svc -n istio-system | grep ingressgateway | awk ' { print $ 4 }')
desc "Let's verify we can call our service"
run "curl -v https://hello-v1.35.239.201.203.xip.io:443/ --resolve hello-v1.35.239.201.203.xip.io:443:$ING_GATEWAY_IP"

run "curl -k https://hello-v1.35.239.201.203.xip.io:443/ --resolve hello-v1.35.239.201.203.xip.io:443:$ING_GATEWAY_IP"