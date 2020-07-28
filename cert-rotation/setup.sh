
echo "verifying everything looks good"

. ./verify-certs.sh


echo "set up sample services"
istioctl kube-inject -f ./resources/sleep.yaml | kubectl apply -f -
istioctl kube-inject -f ./resources/httpbin.yaml | kubectl apply -f -


echo "remove the hpa for istiod"
kubectl delete -n istio-system hpa/istiod 

echo "Turning mTLS to strict"
kubectl apply -f resources/default-peerauth.yaml -n istio-system