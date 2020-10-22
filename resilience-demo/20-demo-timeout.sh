#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


desc "Let's deploy a service that has some delays:"

run "kubectl apply -f $(relative resources/k8s/purchase-history-v1-delay-100.yaml) -n resilience"
run "kubectl get pod -w -n resilience"

desc "This is no good -- we don't want customers to wait because of this delay"
read -s
desc "Let's enforce timeouts"

read -s


run "kubectl apply -f $(relative resources/istio/ph-v1-timeout.yaml) -n istio-demo"

desc "Now we see errors. That's no good either, but it's better than unbounded latency"

read -s
desc "What else can we do?"

