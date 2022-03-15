
source env.sh

istioctl x uninstall --purge -y

kubectl delete ns istio-system
kubectl delete ns istioinaction
kubectl delete ns vm-services