#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


#kubectl  get cm istio-ca-root-cert -o jsonpath="{.data['root-cert\.pem']}" | step certificate inspect -

desc "Let's change the root CA and certs"
read -s

desc "Right now it points to the self-signed cert istio creates on startup"
run "kubectl get secrets -n istio-system"
run "kubectl  get cm istio-ca-root-cert -o jsonpath=\"{.data['root-cert\.pem']}\" | step certificate inspect -"

backtotop
desc "Let's connect Istio to Vault to get an intermediate signing cert (and keys not on disk)"
read -s

desc "First, lets delete the self-signed cert"
run "kubectl delete secret/istio-ca-secret -n istio-system"

desc "Let's see how to bootstrap the intermediate CA"
run "cat resources/vault-istiod/istiod-deploy.yaml"

desc "Let's apply it"
run "kubectl apply -f  resources/vault-istiod/istiod-deploy.yaml"

run "kubectl get pod -n istio-system -w"


backtotop
desc "Now let's check the certs, they should be issued by pki-ca-root"
read -s

run "kubectl  get cm istio-ca-root-cert -o jsonpath=\"{.data['root-cert\.pem']}\" | step certificate inspect -"