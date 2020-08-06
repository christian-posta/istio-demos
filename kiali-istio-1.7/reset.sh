kubectl delete clusterrolebinding kiali-dashboard-admin
kubectl delete clusterrolebinding openid-kiali-dashboard-admin
kubectl delete serviceaccount kiali-dashboard -n istio-system
kubectl -n istio-system apply -f resources/kiali-auth-anonym.yaml