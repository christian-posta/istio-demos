# Install Istio
istioctl manifest apply -y

# Install Sample app
kubectl create ns istioinaction
kubectl label namespace istioinaction istio-injection=enabled --overwrite
kubectl apply -n istioinaction -f resources/k8s/web-api.yaml
kubectl apply -n istioinaction -f resources/k8s/recommendation.yaml
kubectl apply -n istioinaction -f resources/k8s/purchase-history-v1.yaml

kubectl apply -n istioinaction -f resources/k8s/sleep.yaml

# Install Istio resources
kubectl apply -n istioinaction -f resources/istio/web-api-gw.yaml
kubectl apply -n istioinaction -f resources/istio/web-api-gw-vs.yaml