rm pcap/*.*
kubectl apply -n istioinaction -f resources/k8s/sleep.yaml
kubectl delete -f resources/istio/istioinaction-peerauth.yaml