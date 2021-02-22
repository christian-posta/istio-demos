kubectl delete ns istioinaction
istioctl x uninstall --purge
kubectl delete ns istio-system
kubectl delete ns vault