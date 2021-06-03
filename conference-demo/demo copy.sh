#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We want to install the control plane components without any gateways"
run "cat ./resources/control-plane.yaml"
run "kubectl create ns istio-system"
run "istioctl install -y -n istio-system -f ./resources/control-plane.yaml --revision 1-8-3"

backtotop
desc "Verify control plane installed correctly"
read -s

run "kubectl get po -n istio-system"
run "kubectl logs -f -n istio-system deploy/istiod"

desc "This is a problem... "
read -s

backtotop
desc "Let's work around this until Tags feature gets in"
read -s
run "kubectl apply -f ./resources/istiod-service.yaml"

desc "Now let's check the logs"
run "kubectl logs -f -n istio-system deploy/istiod"
