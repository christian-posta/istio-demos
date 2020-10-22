#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "Let's use Istio's circuit breaking / outlier detection to kick out those timedout calls"
read -s

run "cat $(relative resources/istio/ph-dr-circuit-breaking.yaml)"
run "kubectl apply -f $(relative resources/istio/ph-dr-circuit-breaking.yaml) -n resilience"

desc "Now we see the offending, delayed service timed out and ejected from the pool"
read -s

desc "but every time it's timed out and evaluted for ejection, it still throws a 504!!!"
read -s
desc "how can we work around this!?"
read -s

desc "easy: just retry!"

run "kubectl apply -f $(relative resources/istio/recommendation-vs-retry.yaml) -n resilience"
