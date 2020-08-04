#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "We see we have a service deployed"
run "kubectl get pod -n default"

desc "We will use istio ingress gateway to route traffic to our service"
run "kubectl get pod -n istio-system"

desc "To do that we, use the Gateway resources"
run  "cat resources/coolstore-gw.yaml"
run  "kubectl apply -f resources/coolstore-gw.yaml"

backtotop
desc "Let's check  the routes for the ingress gateway"
read -s

INGRESS_POD=$(kubectl get pod -n istio-system  | grep ingressgateway | cut -d ' ' -f 1)
run "istioctl proxy-config route $INGRESS_POD -n istio-system -o json"

desc "Let's give it a route"
run "cat resources/coolstore-vs.yaml"
run "kubectl apply -f resources/coolstore-vs.yaml"
run "istioctl proxy-config route $INGRESS_POD -n istio-system -o json"

desc  "Let's  try curl it"

# try curl it
URL=$(istio-gateway-ip-remote)
run "kubectl get svc -n istio-system"
run "curl -v http://$URL"

desc  "try again"
# no response!
run "curl -v $URL -H 'Host: apiserver.istioinaction.io'"


backtotop
desc "Now let's add TLS termination to our ingress gateway"
read -s

### TLS

desc "First we need to create the secret with the correct key and certs"
run "find resources/certs/3_application"
run "kubectl create -n istio-system secret tls istio-ingressgateway-certs \
--key resources/certs/3_application/private/apiserver.istioinaction.io.key.pem \
--cert resources/certs/3_application/certs/apiserver.istioinaction.io.cert.pem"


# apply gateway-tls
desc "Let's review the Gateway configuration"
run "cat resources/coolstore-gw-tls.yaml"
run "kubectl apply -f resources/coolstore-gw-tls.yaml"

desc "Try call it... won't work"
run  "curl -v -H 'Host: apiserver.istioinaction.io' https://$URL/api/catalog"

desc "Use the right trust chain"
run  "curl -v -H 'Host: apiserver.istioinaction.io' https://$URL/api/catalog  --cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem"

desc "We have to call like this:"
run "curl -H 'Host: apiserver.istioinaction.io' \
https://apiserver.istioinaction.io:443/api/catalog \
--cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve apiserver.istioinaction.io:443:$URL"

backtotop
desc "Lets try do this  with SDS"
read -s

### Let's do this with SDS
desc "First we need to create the secret that we'll use with SDS"
run "kubectl create -n istio-system secret tls apiserver-credential --key=resources/certs/3_application/private/apiserver.istioinaction.io.key.pem --cert=resources/certs/3_application/certs/apiserver.istioinaction.io.cert.pem"

desc "Let's review the Gateway configuration"
run "cat resources/coolstore-gw-tls-sds.yaml"
run "kubectl apply -f resources/coolstore-gw-tls-sds.yaml"

### Curl it again:

run "curl -H 'Host: apiserver.istioinaction.io' \
https://apiserver.istioinaction.io:443/api/catalog \
--cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve apiserver.istioinaction.io:443:$URL"


### Should we redirect the traffic?
#k apply -f resources/coolstore-gw-tls-redirect.yaml 

# We should see a redirect
#curl -v $URL -H "Host: apiserver.istioinaction.io"

backtotop
desc "Using multiple hosts/tls"
read -s

# first create the secret
desc "First we need to create the second secret that we'll use with SDS"
run "kubectl create -n istio-system secret tls catalog-credential --key=resources/certs2/3_application/private/catalog.istioinaction.io.key.pem --cert=resources/certs2/3_application/certs/catalog.istioinaction.io.cert.pem"

# create the fakeservice-2
desc "create the second second service"
run  "kubectl apply -f resources/fakeservice-2.yaml"

desc "apply the catalog service"
run "kubectl apply -f resources/catalog-vs.yaml"

desc "update the gateway to use the multi-tls"
run "cat resources/coolstore-gw-tls-sds-multi.yaml"
run "kubectl apply -f resources/coolstore-gw-tls-sds-multi.yaml"

desc "now call the orig"
run "curl -H 'Host: apiserver.istioinaction.io' \
https://apiserver.istioinaction.io:443/api/catalog \
--cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve apiserver.istioinaction.io:443:$URL"

desc "now call the catalog one"
run "curl -H 'Host: catalog.istioinaction.io' \
https://catalog.istioinaction.io:443/api/catalog \
--cacert resources/certs2/2_intermediate/certs/ca-chain.cert.pem \
--resolve catalog.istioinaction.io:443:$URL"


