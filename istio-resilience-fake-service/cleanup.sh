
# Delete Bookinfo
kubectl delete -n resilience resources/k8s
kubectl delete ns resilience


# Delete Istio
kubectl delete -f resources/install/istio-1.5.yaml
