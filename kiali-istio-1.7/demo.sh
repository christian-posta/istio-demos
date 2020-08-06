#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


desc "Try port forward in k9s and view in browser"
read -s

desc "Kiali by default gets installed with Anonymous auth"

run "kubectl get kiali -n istio-system"
run "kubectl get kiali -n istio-system -o yaml"

backtotop
desc "Kiali provides multiple types of auth"
desc "Let's take a look at token auth first"
read -s

desc "Let's see the kiali config"
run "cat resources/kiali-auth-token.yaml"
run "kubectl apply -f resources/kiali-auth-token.yaml"

desc "Let's create the Service Account and tie rbac to it"
run "kubectl create serviceaccount kiali-dashboard -n istio-system"

desc "Create the binding"
run "kubectl create clusterrolebinding kiali-dashboard-admin --clusterrole=kiali --serviceaccount=istio-system:kiali-dashboard"

desc "Go to the browser"
read -s

desc "Lets get the token"
run "kubectl get secret -n istio-system -o jsonpath=\"{.data.token}\" $(kubectl get secret -n istio-system | grep kiali-dashboard | awk '{print $1}' ) | base64 --decode"

desc "Go to the browser"
read -s

backtotop
desc "Let's try with OIDC"
read -s

desc "Let's see the kiali config"
run "cat resources/kiali-auth-oidc.yaml"
run "kubectl apply -f resources/kiali-auth-oidc.yaml"

desc "Lets associate a rolebinding with a user"
# kubectl create clusterrolebinding openid-kiali-dashboard-admin --clusterrole=kiali --user="admin@example.com"
run "kubectl create clusterrolebinding openid-kiali-dashboard-admin --clusterrole=kiali --user=\"admin@example.com\""
