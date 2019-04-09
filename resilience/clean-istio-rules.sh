#!/bin/bash


# for v1alpha3
kubectl delete virtualservice recommendation
kubectl delete virtualservice preference
kubectl delete destinationrule --all