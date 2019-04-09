#!/bin/bash
. $(dirname ${BASH_SOURCE})/../util.sh

desc "Start with a clean cluster with just bookinfo deployed"
run "kubectl get pod -n default"


desc "Show metrics / Grafana"
desc "kubectl port-forward -n istio-system $(kubectl get pod -n istio-system | grep -i ^grafana | cut -d ' ' -f 1) 3000:3000"
read -s

backtotop
PRODUCTPAGE_POD=$(kubectl get pod | grep productpage | awk '{print $1}')
desc "Show clusters running on the istio-proxy"
run "istioctl proxy-config clusters $PRODUCTPAGE_POD"

backtotop
desc "Start adding 100 services"
run "./$(relative boot-100-svcs.sh)"


backtotop
desc "Show memory increasing in grafana"
read -s


desc "Now show all clusters in istio-proxy"
run "istioctl proxy-config clusters $PRODUCTPAGE_POD"

backtotop
desc "We'll use the Sidecar resource to limit what clusters the istio-proxy cal talk to"
run "cat $(relative bookinfo-sidecar.yaml)"


desc "Add Sidecar resource"
run "kubectl apply -f $(relative bookinfo-sidecar.yaml)"

backtotop
desc "Show all clusters"
run "istioctl proxy-config clusters $PRODUCTPAGE_POD"

backtotop
desc "Show mem not dropping in Grafana"
read -s

desc "Purge memory"
run "./$(relative purge-bookinfo-mem.sh)"

desc "Show memory usage in Grafana"
read -s