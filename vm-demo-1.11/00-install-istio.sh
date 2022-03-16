source env.sh

kubectl create ns istio-system

# Install control plane
istioctl1.11 install -y -f resources/istio/vm-cluster.yaml

# Install east-west gateway
istioctl1.11 install -y -f resources/istio/vm-cluster-eastwest.yaml

# Expose the control plane on the E/W gateway
kubectl apply -f resources/istio/expose-istiod.yaml

# Expose the workloads on the E/W gateway
kubectl apply -f resources/istio/expose-services.yaml

# install sample app
kubectl create ns istioinaction
kubectl label namespace istioinaction istio-injection=enabled
kubectl apply -f resources/httpbin.yaml -n istioinaction
kubectl apply -f resources/sleep.yaml -n istioinaction


# prep vm namespace
kubectl create namespace $VM_NAMESPACE
kubectl create serviceaccount $SERVICE_ACCOUNT -n $VM_NAMESPACE