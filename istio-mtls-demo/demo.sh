#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

URL=$(k get svc -n istio-system | grep ingressgateway | awk '{ print $4 }')

desc "Our serivces web->recommendation->purchase-history:"
run "kubectl get pod -n istioinaction"


desc "Calling, we should see the chain of services"

run "curl -H \"Host: istioinaction.io\" $URL"

desc "Let's caputure the traffic between web->recommendation"
RECOMMENDATION_IP=$(kubectl get pod -o wide | grep recommendation | awk '{ print $6 }')
WEB_POD=$(kubectl get pod -l app=web-api -n istioinaction -o jsonpath={.items..metadata.name})

desc "We need the IP of Recommendation"
echo "Recommendation IP: $RECOMMENDATION_IP"

read -s

# split the screen and run the polling script in bottom script
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl sniff -i eth0 -o $(relative pcap/capture1.pcap) $WEB_POD -n istioinaction -f '((tcp) and (net $RECOMMENDATION_IP))'" C-m

read -s

backtotop

desc "Let's send some traffic"
run "curl -H \"Host: istioinaction.io\" $URL"
run "curl -H \"Host: istioinaction.io\" $URL"


tmux send-keys -t 1 C-c

desc "Now let's open the pcap file in wireshark"
read -s

tmux send-keys -t 1 "exit" C-m