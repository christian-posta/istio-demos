#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "We want to install the control plane components without any gateways"
run "cat ./resources/control-plane.yaml"
run "kubectl create ns istio-system"
run "kubectl apply -f ./resources/istiod-service.yaml"
run "istioctl install -y -n istio-system -f ./resources/control-plane.yaml --revision 1-9-5"

backtotop
desc "Verify control plane installed correctly"
read -s
run "kubectl get po -n istio-system"
