#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "Let's simulate some issues with v1 deployment. We'll deploy a version of the svc that generates faults 50% of the time"
read -s


# split the screen and run the polling script in bottom script
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "sh $(relative bin/poll_gateway.sh)" C-m

read -s
#desc "first we need to disable automatic retries otherwise we won't see the faults"
desc "Deploy updated v2 svc"
run "kubectl apply -f $(relative resources/k8s/purchase-history-v1-error-50.yaml) -n resilience"

desc "Now, let's add a Retry policy for our service to smooth out the errors"
run "kubectl apply -f $(relative resources/istio/recommendation-vs-retry.yaml) -n resilience"

desc "Note, this helps with most of the errors.. let's discuss what's happening here"
desc "Clean up/restore -- will come back to retries"
