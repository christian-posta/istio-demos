#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

# grafana: http://localhost:3000
# kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 


# jaeger: http://localhost:16686
# kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686



SOURCE_DIR=$PWD



desc "So we have v1 of our recommendation service"
run "kubectl get pod -n istio-demo"


desc "That v1 is taking some load..."
read -s

# split the screen and run the polling script in bottom script
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "sh $(relative bin/poll_customer.sh)" C-m


read -s
desc "Let's say we want to deploy a new version of our service, v2"

read -s

desc "we will create a new deployment and inject the Istio sidecar. Let's take a look at what that looks like:"

run "cat $(relative kube/recommendation-v2-deployment.yml)"
run "istioctl kube-inject  -f $(relative kube/recommendation-v2-deployment.yml)"

desc "Okay. let's actually create it:"
read -s
run "kubectl apply -f  $(relative kube/recommendation-v2-deployment.yml) -n istio-demo"

run "kubectl get pod -w -n istio-demo"


backtotop

desc "Woah: we don't want this. We dont want to release this version"
read -s

# show routing?
#
# everything to v1?
desc "Let's route everything to v1"
run "kubectl apply -f $(relative istio/recommendation-service-all-v1.yml) -n istio-demo"

desc "Let's do a canary release of v2"
run "kubectl apply -f $(relative istio/recommendation-service-v1-v2-90-10.yml) -n istio-demo"

desc "Using Istio, let's purposefully balance traffic between v1 and v2"
run "kubectl apply -f $(relative istio/recommendation-service-v1-v2-50-50.yml) -n istio-demo"


