kind delete cluster --name kind1
kind delete cluster --name kind2
kind delete cluster --name kind3

kubectl config delete-context istio-1
kubectl config delete-context istio-2
kubectl config delete-context istio-3
