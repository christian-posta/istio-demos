#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


desc "We want to install the control plane components without any gateways"
run "cat ./resources/control-plane-hold-app.yaml"

run "istioctl1.10 install -y -n istio-system -f ./resources/control-plane-hold-app.yaml --revision 1-10-0"

desc "Let's slowly introduce our servcies into the mesh"
run "kubectl get po -n istio-system"

backtotop
desc "Let's label the namespace with the new revision"
read -s

run "kubectl label namespace istioinaction istio.io/rev=1-10-0 --overwrite"

desc "Now let's deploy a canary version of one of our existing services"
run "kubectl -n istioinaction apply -f resources/sample-apps-canary/web-api.yaml"

desc "Let's see that it has the sidecar injected"
run "kubectl -n istioinaction get po"
run "istioctl proxy-status"
run "kubectl -n istioinaction describe po $(kubectl -n istioinaction get pod | grep canary | awk '{print $1}')"

desc "if all looks good, we can rollout the original version"
run "kubectl -n istioinaction rollout restart deploy/web-api"
run "kubectl -n istioinaction get po"


desc "repeat the process to get all of the workloads individually into the mesh"
desc "(speeding it up...)"
kubectl -n istioinaction rollout restart deploy/recommendation
kubectl -n istioinaction rollout restart deploy/purchase-history-v1
kubectl -n istioinaction rollout restart deploy/sleep

kubectl -n istioinaction delete -f resources/sample-apps-canary/web-api.yaml