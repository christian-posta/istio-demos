


istioctl1.9 install -y --set profile=minimal
kubectl apply -f resources/default-peerauth-strict.yaml -n istio-system

kubectl create ns demo
kubectl label ns demo istio-injection=enabled
kubectl apply -f resources/httpbin.yaml -n demo


kubectl create ns fake
kubectl label ns fake istio-injection=enabled
kubectl apply -f resources/fakeservice.yaml -n fake

kubectl apply -f resources/sleep.yaml -n default


kubectl rollout status -n demo deploy/httpbin
kubectl rollout status -n fake deploy/fakeservice
kubectl rollout status -n default deploy/sleep