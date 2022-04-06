#!/bin/bash


kubectl delete CustomResourceDefinition spiffeids.spiffeid.spiffe.io
kubectl delete -n spire serviceaccount spire-agent
kubectl delete -n spire configmap spire-agent
kubectl delete -n spire deployment spire-agent
kubectl delete csidriver csi.spiffe.io
kubectl delete -n spire configmap spire-server
kubectl delete -n spire service spire-server
kubectl delete -n spire serviceaccount spire-server
kubectl delete -n spire statefulset spire-server
kubectl delete clusterrole spire-server-trust-role spire-agent-cluster-role
kubectl delete clusterrolebinding spire-server-trust-role-binding spire-agent-cluster-role-binding
kubectl delete namespace spire

