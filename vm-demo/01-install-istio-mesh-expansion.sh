source env.sh
kubectl create ns istio-system
istioctl install -f resources/vmintegration.yaml

