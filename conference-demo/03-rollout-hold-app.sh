#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


desc "Take a look at the existing workloads and the ordering of their container start"
desc "Press Enter to continue"
read -s

desc "Let's configure Istio to change this behavior"
run "cat ./resources/control-plane-hold-app.yaml"

desc "Let's upgrade Istio to 1.10 and enable this new behavior"
run "istioctl1.10 install -y -n istio-system -f ./resources/control-plane-hold-app.yaml --revision 1-10-0"

backtotop
desc "Let's label the namespace with the new revision"
read -s

run "kubectl label namespace istioinaction istio.io/rev=1-10-0 --overwrite"

desc "Now let's deploy a canary version of one of our existing services"
run "kubectl -n istioinaction apply -f resources/sample-apps-canary/web-api.yaml"

desc "Let's see that it has the sidecar injected"
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

backtotop
desc "Wait for all sidecars to come up"
run "kubectl -n istioinaction get po -w"

desc "Now all sidecars should be on the 1.10 control plane"
run "istioctl proxy-status"

desc "So we can delete the 1-9-5 control plane"
run "istioctl x uninstall -f resources/control-plane.yaml --revision 1-9-5"
