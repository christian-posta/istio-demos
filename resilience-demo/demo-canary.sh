#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "So we have v1 of our purchase-history service"
run "kubectl get pod -n resilience"


desc "That v1 is taking some load..."
read -s

# split the screen and run the polling script in bottom script
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "sh $(relative bin/poll_gateway.sh)" C-m


read -s
desc "Let's say we want to deploy a new version of our service, v2"

read -s

desc "Let's take a look at what that looks like:"
run "cat $(relative resources/k8s/purchase-history-v2.yaml)"

desc "Okay. let's actually create it and auto-injection:"
read -s
run "kubectl apply -f  $(relative resources/k8s/purchase-history-v2.yaml) -n resilience"

run "kubectl get pod -w -n resilience"


backtotop

desc "Note, we stil get traffic to v1"
desc "let's see Istio's VirtualService for this:"
run "kubectl -n resilience get virtualservice.networking puchase-history-vs -o yaml"
read -s

desc "Let's do a canary release of v2"
run "kubectl apply -f $(relative resources/istio/ph-v1-v2-90-10.yaml) -n resilience"

desc "Using Istio, let's purposefully balance traffic between v1 and v2"
run "kubectl apply -f $(relative resources/istio/ph-v1-v2-50-50.yaml) -n resilience"


desc "Using Istio, let's complete the canary routing to v2"
run "kubectl apply -f $(relative resources/istio/ph-v1-v2-0-100.yaml) -n resilience"