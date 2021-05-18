#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "The data plane is always part of the application"
desc "Let's make sure 100% of traffic will be going to the stable version"
run "cat ./scenario-1-ing-gw/canary/web-api-gw-stable.yaml"
run "cat ./scenario-1-ing-gw/canary/canary-vs.yaml"

desc "Before we apply this, we need to define the subsets"
run "cat ./scenario-1-ing-gw/canary/canary-dr.yaml"

desc "Let's apply these resources"
run "kubectl -n istioinaction -f ./scenario-1-ing-gw/canary/canary-dr.yaml"
run "kubectl -n istioinaction -f ./scenario-1-ing-gw/canary/web-api-gw-stable.yaml"
run "kubectl -n istioinaction -f ./scenario-1-ing-gw/canary/canary-vs.yaml"

desc "Now we should always expect all traffic to go to the stable workloads"
read -s
backtotop

desc "Install new revision of control plane"
run "istioctl1.10 install -y --set profile=minimal --revision 1-10-0 --set components.pilot.k8s.replicaCount=3"
run "kubectl get po -n istio-system"

desc "Let's start a canary deployment of the web-api service with the new 1-10-0 dataplane"
run "istioctl kube-inject -f scenario-1-ing-gw/canary/web-api.yaml --meshConfigMapName istio-1-10-0 --injectConfigMapName istio-sidecar-injector-1-10-0  | kubectl apply -n istioinaction -f -"

desc "All of the traffic should still be going to the stable 1-9-5 version"
desc "Let's canary the release of the 1-10-0 data plane update"
run "cat ./scenario-1-ing-gw/canary/web-api-canary-30.yaml"
run "kubectl -n istioinaction -f ./scenario-1-ing-gw/canary/web-api-gw-canary-30.yaml"

desc "If this looks good, we can send all of the traffic to the new version"
run "kubectl -n istioinaction -f ./scenario-1-ing-gw/canary/web-api-gw-canary-100.yaml"

