#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

URL=$(k get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')
RECOMMENDATION_IP=$(kubectl get svc -o wide | grep recommendation | awk '{ print $3 }')

desc "Istio has auto-mtls when the proxies can support it"
desc "for example, let's deploy a service that doesn't have the istio proxy deployed next to it"

desc "Notice no sidecar proxy in the sleep container"
run "kubectl get po -n istioinaction"

backtotop

SLEEP_POD=$(kubectl get pod -l app=sleep -n istioinaction -o jsonpath={.items..metadata.name})
desc "Lets try make a call from sleep->recommendation"
run "kubectl exec $SLEEP_POD  -c sleep -n istioinaction -- curl -s http://recommendation.istioinaction:8080/"

desc "The call completed successfully. But how was the mTLS established?"
desc "Let's capture the traffic and see"

tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl sniff -i eth0 -o $(relative pcap/capture2.pcap) $SLEEP_POD -n istioinaction -f '((tcp) and (net $RECOMMENDATION_IP))'" C-m

read -s

backtotop

desc "Let's send some traffic"
run "kubectl exec $SLEEP_POD  -c sleep -n istioinaction -- curl -s http://recommendation.istioinaction:8080/"

tmux send-keys -t 1 C-c

desc "Now let's open the pcap file in wireshark"
read -s

tmux send-keys -t 1 "exit" C-m


desc "Istio by default is in permissive mode"
desc "Lets enable strict mTLS"
read -s
run "cat resources/istio/istioinaction-peerauth.yaml"

desc "Let's apply this peer authentication policy"
run "kubectl apply -f resources/istio/istioinaction-peerauth.yaml"

desc "Now try call sleep->recommendation"
run "kubectl exec $SLEEP_POD  -c sleep -n istioinaction -- curl -s http://recommendation.istioinaction:8080/"

desc "It fails as expected" 
read -s

desc "If we inject the sidecar, the call will work and it will be over mTLS"
run "kubectl apply -f <(istioctl kube-inject -f resources/k8s/sleep.yaml) -n istioinaction"
run "kubectl get po -n istioinaction"

SLEEP_POD=$(kubectl get pod -l app=sleep -n istioinaction -o jsonpath={.items..metadata.name})

desc "Now try again"
run "kubectl exec $SLEEP_POD  -c sleep -n istioinaction -- curl -s http://recommendation.istioinaction:8080/"