source env.sh
kubectl create ns istio-system
istioctl1.7 install -f resources/vmintegration-multi-network.yaml

