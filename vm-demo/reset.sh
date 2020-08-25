rm -fr ./work
kubectl delete peerauthentication -n istio-system default
kubectl delete svc --all -n vm-services
kubectl delete workloadentry --all -n vm-services
