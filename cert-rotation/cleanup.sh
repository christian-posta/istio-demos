
rm -fr ./certs

kubectl delete -f resources/sleep.yaml
kubectl delete -f resources/httpbin.yaml