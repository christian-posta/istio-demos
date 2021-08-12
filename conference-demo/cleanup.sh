kubectl delete ns istioinaction
kubectl delete ns istio-ingress
istioctl x uninstall --purge -y
kubectl delete ns istio-system
kubectl delete ns vault