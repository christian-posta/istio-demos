#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "Let's install a new control plane with new revision"
desc "Let's make sure we can upgrade"
run "istioctl1.10 x precheck"
run "istioctl1.10 analyze"

desc "We should be good to install!"
run "istioctl1.10 install -y --set profile=minimal --revision 1-10-0"
run "kubectl -n istio-system get po"

desc "Let's add a new tag for this as prod-canary"
run "istioctl1.10 x revision tag set prod-canary --revision 1-10-0 --overwrite"

desc "We now have two control planes and two tags"
run "istioctl1.10 x revision tag list"

desc "Everything still on the default tag"
run "istioctl1.10 ps"

