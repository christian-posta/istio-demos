#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "Let's slowly introduce our servcies into the mesh"
run "kubectl get po -n istioinaction"
run "kubectl -n istioinaction exec -it deploy/sleep -c sleep -- curl http://web-api:8080"

backtotop
desc "Let's label the namespace for sidecar injection"
run "kubectl label namespace istioinaction istio-injection=enabled"

desc "Now let's deploy a canary version of one of our existing services"
run "kubectl -n istioinaction apply -f resources/sample-apps-canary/web-api.yaml"

desc "Let's see that it has the sidecar injected"
run "kubectl -n istioinaction get po"
run "kubectl -n istioinaction exec -it deploy/sleep -c sleep -- curl http://web-api:8080"

desc "if all looks good, we can rollout the original version"
run "kubectl -n istioinaction rollout restart deploy/web-api"
run "kubectl -n istioinaction get po"


desc "repeat the process to get all of the workloads individually into the mesh"
desc "(speeding it up...)"
kubectl -n istioinaction rollout restart deploy/recommendation
kubectl -n istioinaction rollout restart deploy/purchase-history-v1
kubectl -n istioinaction rollout restart deploy/sleep

run "kubectl -n istioinaction get po -w"
