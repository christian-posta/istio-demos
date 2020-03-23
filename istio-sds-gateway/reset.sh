kubectl delete -f resources/v1-https.yaml
kubectl delete -f resources/cert-hello-v1.yaml
kubectl delete secret -n istio-system hello-v1-cert