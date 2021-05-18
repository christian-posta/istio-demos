#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


desc "Let's restart the workloads in sample-ns"
run "kubectl delete po --all -n sample-ns"

desc "Now we see some workloads on the new canary revision"
run "istioctl1.10 ps"

desc "If things look good, we can change the stable-prod tag"
run "istioctl1.10 x revision tag set prod-stable --revision 1-10-0 --overwrite"
run "istioctl1.10 ps"

desc "Now let's restart the workloads"
run "kubectl delete po -n istioinaction --all"
run "istioctl1.10 ps"

