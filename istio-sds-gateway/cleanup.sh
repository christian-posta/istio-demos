kubectl delete -f resources/fakeservice.yaml
kubectl delete -f resources/fakeservice-2.yaml
kubectl delete -f resources/coolstore-gw.yaml
kubectl delete -f resources/coolstore-vs.yaml
kubectl delete -f resources/coolstore-gw-tls.yaml
kubectl delete -f resources/coolstore-gw-tls-redirect.yaml
kubectl delete -f resources/coolstore-gw-tls-sds.yaml
kubectl delete -f resources/coolstore-gw-tls-sds-multi.yaml
kubectl delete -f resources/catalog-vs.yaml
kubectl delete secret -n istio-system apiserver-credential 
kubectl delete secret -n istio-system catalog-credential 
kubectl delete secret -n istio-system istio-ingressgateway-certs   