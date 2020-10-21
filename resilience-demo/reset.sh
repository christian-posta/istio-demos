# Delete VSs we don't want around
kubectl delete -n resilience virtualservices.networking purchase-history-vs 
kubectl delete -n resilience virtualservices.networking recommendation-vs 
kubectl delete -n resilience destinationrule purchase-history-dr

# delete v2 of PH
kubectl delete -n resilience -f resources/k8s/purchase-history-v2.yaml
kubectl delete -n resilience -f resources/k8s/purchase-history-v1-error-50.yaml

kubectl apply -n resilience -f resources/k8s/web-api.yaml
kubectl apply -n resilience -f resources/k8s/recommendation.yaml
kubectl apply -n resilience -f resources/k8s/purchase-history-v1.yaml

# set all traffic to v1
kubectl apply -n resilience -f resources/istio/ph-all-v1.yaml
kubectl apply -n resilience -f resources/istio/disable-auto-retries.yaml