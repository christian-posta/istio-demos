#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh


desc "Let's deploy a service that has some delays:"
desc "Again, let's disable automatic retries to see exactly how this works"
run "kubectl apply -f $(relative istio/disable-auto-retries.yml)"

run "kubectl apply -f <(istioctl kube-inject -f $(relative kube/recommendation-v2-delay-deployment.yml))"
run "kubectl get pod -w"

desc "This is no good -- we don't want customers to wait because of this delay"
read -s
desc "Let's enforce timeouts"

read -s


run "kubectl apply -f $(relative istio/recommendation-service-timeout.yml)"

desc "Now we see errors. That's no good either, but it's better than unbounded latency"

read -s
desc "What else can we do?"
