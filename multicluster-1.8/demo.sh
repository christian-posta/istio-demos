#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

. ./env.sh

export CLUSTER2_GW_ADDR=$(kubectl get --context=$CLUSTER_2 svc --selector=app=istio-ingressgateway  -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

export SLEEP_POD=$(kubectl get --context=$CLUSTER_1 -n foo pod -l app=sleep -o jsonpath={.items..metadata.name})

desc "We have sleep in cluster 1 and httpbin in cluster 2"
desc "let's try call httpbin"
run "kubectl exec --context=$CLUSTER_1 $SLEEP_POD -n foo -c sleep -- curl -I httpbin.bar.global:8000/headers"

desc "Looks like we cannot"
desc "Lets add a ServiceEntry so we can talk to the 'global' mesh"
read -s

backtotop

cat > temp/httpbin-se.yaml <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: httpbin-bar
spec:
  hosts:
  # must be of form name.namespace.global
  - httpbin.bar.global
  # Treat remote cluster services as part of the service mesh
  # as all clusters in the service mesh share the same root of trust.
  location: MESH_INTERNAL
  ports:
  - name: http1
    number: 8000
    protocol: http
  resolution: DNS
  addresses:
  # the IP address to which httpbin.bar.global will resolve to
  # must be unique for each remote service, within a given cluster.
  # This address need not be routable. Traffic for this IP will be captured
  # by the sidecar and routed appropriately.
  - 240.0.0.2
  endpoints:
  # This is the routable address of the ingress gateway in cluster2 that
  # sits in front of sleep.foo service. Traffic from the sidecar will be
  # routed to this address.
  - address: ${CLUSTER2_GW_ADDR}
    ports:
      http1: 15443 # Do not change this port value
EOF

run "cat temp/httpbin-se.yaml"
backtotop

desc "First we need to create a service entry"
read -s
run "kubectl --context $CLUSTER_1 -n foo apply -f temp/httpbin-se.yaml"

desc "Let's see if we can reach the httpbin workload running in cluster 2"
run "kubectl exec --context=$CLUSTER_1 $SLEEP_POD -n foo -c sleep -- curl  httpbin.bar.global:8000/headers"