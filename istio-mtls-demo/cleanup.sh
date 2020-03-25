
# Delete Bookinfo
kubectl delete -n istioinaction -f resources/k8s
kubectl delete ns istioinaction


# Delete Istio
kubectl delete -f resources/install/istio-1.5.yaml
