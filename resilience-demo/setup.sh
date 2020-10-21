# Install Istio
#istioctl manifest apply -y

# Install Sample app
kubectl create ns resilience
kubectl label namespace resilience istio-injection=enabled --overwrite
kubectl apply -n resilience -f resources/k8s/web-api.yaml
kubectl apply -n resilience -f resources/k8s/recommendation.yaml
kubectl apply -n resilience -f resources/k8s/purchase-history-v1.yaml

# Install Istio resources
kubectl apply -n resilience -f resources/istio/web-api-gw.yaml
kubectl apply -n resilience -f resources/istio/web-api-gw-vs.yaml

kubectl apply -n resilience -f resources/istio/ph-all-v1.yaml
kubectl apply -n resilience -f resources/istio/disable-auto-retries.yaml