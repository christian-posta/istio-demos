#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


desc "Let's simulate some issues with v2 deployment. Using Istio, let's inject periodic faults into v2"
run "kubectl apply -f $(relative istio/recommendation-service-fault.yml)"

desc "Now, let's add a Retry policy for our service to smooth out the errors"
run "kubectl apply -f $(relative istio/preference-service-retry.yml)"

desc "Clean up/restore -- will come back to retries"

run "istioctl delete virtualservice preference"
run "kubectl apply -f $(relative istio/recommendation-service-v1-v2-50-50.yml)"

