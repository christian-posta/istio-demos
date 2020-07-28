#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

SLEEP_POD=$(kubectl get po -n default | grep sleep | awk '{ print $1 }')

desc "Let's look at k9s and explore our environment"
read -s

# Call once to see the output
backtotop
desc "To get a sense of what the fake service responds with, let's call it within sleep container"
read -s
tmux split-window -v -d -c $SOURCE_DIR
tmux select-pane -t 0
tmux send-keys -t 1 "kubectl exec -it $SLEEP_POD -c sleep -- curl fakeservice" C-m
read -s

# Call a few and see how the load balancing works
desc "If we call a handful of times, we see load balance across different workloads"
for i in {0..5}; do kubectl exec -it $SLEEP_POD -c sleep -- curl fakeservice | jq '.ip_addresses' && printf '\n'; done
read -s

# Let's see the output of the endpoints for this cluster
backtotop
desc "Let's see the different endpoints Envoy knows about in the sleep container for fakeservice"
read -s

run "istioctl proxy-config endpoints $SLEEP_POD --cluster \"outbound|80||fakeservice.default.svc.cluster.local\" -o json"

# Let's take a look at outlier detection:
backtotop
desc "Let's enable locality priority weights"
read -s

desc "To do that we need to enable outlier detection (passive healthchecking)"
run "cat resources/fakeservice/fakeservice-dr.yaml"

desc "Let's enable outlier detection"
run "kubectl apply -f resources/fakeservice/fakeservice-dr.yaml"

# Check the endpoints again; we should see priority for some endpoints
# Default priority is 0 (or omitted)
backtotop
desc "Now if we check, we should see priority groups"
read -s

run "istioctl proxy-config endpoints $SLEEP_POD --cluster \"outbound|80||fakeservice.default.svc.cluster.local\" -o json"

# Now if we call again, we should see the endpoints are more constrainted
# Woohoo!! We have locality built in!
backtotop
desc "Now if we call again, we should see the endpoints are more constrainted"
read -s

run "for i in {0..5}; do kubectl exec -it $SLEEP_POD -c sleep -- curl fakeservice | jq '.ip_addresses' && printf '\n'; done"

# Call them individually, see that some are good and some are bad (acting good)
desc "We can call individually to see some are good and some are bad (acting good)"
read -s
tmux send-keys -t 1 "kubectl exec -it $SLEEP_POD -c sleep -- curl fakeservice" C-m
read -s

## Now do a Port Forward to the Envoy admin
#(do we want to do this behind the scenes? or just in k9s?)
## and go to:
backtotop
desc "Let's Port forward to 15000 and check the clusters"
read -s
#http://localhost:15000/clusters
## evaluate the endpoints for fakeservice

## Now deploy the bad service!
backtotop
desc "Let's make the bad services mis-behave"
read -s
run "kubectl apply -f resources/fakeservice/fakeservice-bad.yaml"

# Now call a few times...
###### Split the screen here
desc "Now call it a few times and check the health behavior in the browser"
read -s
tmux send-keys -t 1 "kubectl exec -it $SLEEP_POD -c sleep -- curl fakeservice" C-m
