#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


desc "We have two different namespaces for two different teams"
run "kubectl -n demo get po"
run "kubectl -n fake get po"

desc "We have Istio control plane and no ingress"
run "kubectl -n istio-system get po"

backtotop
desc "We cannot call the workloads directly"
read -s

run "kubectl -n default exec -it deploy/sleep -- curl -v httpbin.demo:8000/headers"

backtotop
desc "Let's use gateway injection to enable gateways for each team"
read -s

run "cat resources/demo-gateway.yaml"
run "kubectl -n demo apply -f resources/demo-gateway.yaml"
run "kubectl -n demo get po"

desc "Now let's create some GW/VS resources"
run "cat resources/demo-gw-vs.yaml"
run "kubectl -n demo apply -f resources/demo-gw-vs.yaml"
run "kubectl -n default exec -it deploy/sleep -- curl -H 'Host: httpbin.solo.io' http://demo-gw.demo/headers"

# another team in the fake namespace
backtotop
desc "What about for the other team?"
read -s

run "cat resources/fake-gateway.yaml"
run "kubectl -n fake apply -f resources/fake-gateway.yaml"
run "kubectl -n fake get po"

desc "Now let's create some GW/VS resources"
run "cat resources/fake-gw-vs.yaml"
run "kubectl -n fake apply -f resources/fake-gw-vs.yaml"
run "kubectl -n default exec -it deploy/sleep -- curl -H 'Host: fakeservice.solo.io' http://fake-gw.fake"