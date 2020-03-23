#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


desc "Let's simulate some issues with v2 deployment. Using Istio, let's inject periodic faults into v2"
desc "first we need to disable automatic retries otherwise we won't see the faults"
run "kubectl apply -f $(relative istio/disable-auto-retries.yml) -n istio-demo"

desc "now let's inject faults"
run "kubectl apply -f $(relative istio/recommendation-service-fault.yml) -n istio-demo"

desc "Now, let's add a Retry policy for our service to smooth out the errors"
run "kubectl apply -f $(relative istio/preference-service-retry.yml) -n istio-demo"

desc "Note, this helps with most of the errors.. let's discuss what's happening here"

desc "Clean up/restore -- will come back to retries"

run "kubectl delete virtualservice.networking preference -n istio-demo"
run "kubectl apply -f $(relative istio/customer-virtual-service.yaml) -n istio-demo"
run "kubectl apply -f $(relative istio/recommendation-service-v1-v2-50-50.yml) -n istio-demo"