
source env.sh

. ./reset.sh

kubectl delete namespace vm-services
kubectl delete peerauthentication -n istio-system default