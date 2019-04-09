#!/bin/bash

kubectl delete all --all
kubectl delete route --all
kubectl delete routerules --all
kubectl delete destinationpolicy --all