#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "foo"

INGRESS_POD=$(kubectl get pod -n istio-system  | grep ingressgateway | cut -d ' ' -f 1)

# Create Gw
kubectl apply -f resources/coolstore-gw.yaml

# check routes
istioctl proxy-config route istio-ingressgateway-68c4b7698c-ntkgj -n istio-system -o json

# create VS, give it a route
kubectl apply -f resources/coolstore-vs.yaml

# check routes
istioctl proxy-config route istio-ingressgateway-68c4b7698c-ntkgj -n istio-system -o json

# try curl it
URL=$(istio-gateway-ip-remote)
curl -v $URL

# no response!
curl -v $URL -H "Host: apiserver.istioinaction.io"



### TLS

# create secret that's mounted in GW
kubectl create -n istio-system secret tls istio-ingressgateway-certs \
--key resources/certs/3_application/private/apiserver.istioinaction.io.key.pem \
--cert resources/certs/3_application/certs/apiserver.istioinaction.io.cert.pem

# apply gateway-tls
kubectl apply -f resources/coolstore-gw-tls.yaml 

# Try call it... won't work
curl -v -H "Host: apiserver.istioinaction.io" https://$URL/api/catalog

# Use the right trust chain
curl -v -H "Host: apiserver.istioinaction.io" https://$URL/api/catalog  --cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem

# We have to call like this:
curl -H "Host: apiserver.istioinaction.io" \
https://apiserver.istioinaction.io:443/api/catalog \
--cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve apiserver.istioinaction.io:443:$URL



### Let's do this with SDS
kubectl create -n istio-system secret tls apiserver-credential --key=resources/certs/3_application/private/apiserver.istioinaction.io.key.pem --cert=resources/certs/3_application/certs/apiserver.istioinaction.io.cert.pem

### Curl it again:

curl -H "Host: apiserver.istioinaction.io" \
https://apiserver.istioinaction.io:443/api/catalog \
--cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve apiserver.istioinaction.io:443:$URL


### Should we redirect the traffic?
k apply -f resources/coolstore-gw-tls-redirect.yaml 

# We should see a redirect
curl -v $URL -H "Host: apiserver.istioinaction.io"


### Using multiple hosts/tls


# first create the secret
kubectl create -n istio-system secret tls catalog-credential --key=resources/certs2/3_application/private/catalog.istioinaction.io.key.pem --cert=resources/certs2/3_application/certs/catalog.istioinaction.io.cert.pem

# create the fakeservice-2
k apply -f resources/fakeservice-2.yaml 

#apply the catalog service:
kubectl apply -f resources/catalog-vs.yaml

# update the gateway to use the multi-tls
kubectl apply -f resources/coolstore-gw-tls-sds-multi.yaml

# now call the orig
curl -H "Host: apiserver.istioinaction.io" \
https://apiserver.istioinaction.io:443/api/catalog \
--cacert resources/certs/2_intermediate/certs/ca-chain.cert.pem \
--resolve apiserver.istioinaction.io:443:$URL

# now call the catalog one
curl -H "Host: catalog.istioinaction.io" \
https://catalog.istioinaction.io:443/api/catalog \
--cacert resources/certs2/2_intermediate/certs/ca-chain.cert.pem \
--resolve catalog.istioinaction.io:443:$URL


