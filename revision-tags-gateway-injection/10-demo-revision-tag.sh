#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "A tag is a pointer to a revision introduced in Istio 1.10"
desc "We don't have any tags to start off with"
run "istioctl1.10 x revision tag list"

desc "Let's add the current (non rev, default) as the prod-stable tag"
run "istioctl1.10 x revision tag set prod-stable --revision default"

desc "Let's also add a canary tag and point to default revison"
run "istioctl1.10 x revision tag set prod-canary --revision default"
run "istioctl1.10 x revision tag list"

desc "Tags are implemented as webhook injectors"
run "kubectl get mutatingwebhookconfiguration"

desc "Let's remove the istio-injection label and add our tag"
run "kubectl label ns istioinaction istio-injection-"
run "kubectl label ns istioinaction istio.io/rev=prod-stable"

desc "Let's bounce the workloads to pick up the new revision (not new)"
run "kubectl delete po --all -n istioinaction"

desc "sample-ns does not have any injection, let's set a label on it"
run "kubectl label ns sample-ns istio.io/rev=prod-canary"
run "kubectl delete po --all -n sample-ns"


desc "What control plane are the workloads pointed to?"
run "istioctl1.10 ps"
