echo "Make sure you have Istio installed! (press ENTER to continue)"
read -s

kubectl apply -f resources/sleep.yaml
kubectl apply -f resources/fakeservice/fakeservice-vs.yaml
kubectl apply -f resources/fakeservice/fakeservice-good.yaml
kubectl apply -f resources/fakeservice/fakeservice-svc.yaml