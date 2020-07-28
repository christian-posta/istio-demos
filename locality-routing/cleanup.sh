kubectl delete -f resources/sleep.yaml
kubectl delete -f resources/fakeservice/fakeservice-vs.yaml
kubectl delete -f resources/fakeservice/fakeservice-dr.yaml
kubectl delete -f resources/fakeservice/fakeservice-good.yaml
kubectl delete -f resources/fakeservice/fakeservice-svc.yaml