# Starting from fresh cluster install....

kubectl --context istio-1 create ns istio-system
kubectl --context=istio-1 label namespace istio-system topology.istio.io/network=network1

kubectl --context istio-2 create ns istio-system
kubectl --context=istio-2 label namespace istio-system topology.istio.io/network=network2

kubectl --context istio-3 create ns istio-system
kubectl --context=istio-3 label namespace istio-system topology.istio.io/network=network3


# Install secrets
pushd ./certs/
kubectl create secret generic cacerts -n istio-system --from-file=cluster1/ca-cert.pem --from-file=cluster1/ca-key.pem --from-file=cluster1/root-cert.pem  --from-file=cluster1/cert-chain.pem

kubectl --context istio-2 create secret generic cacerts -n istio-system   --from-file=cluster2/ca-cert.pem       --from-file=cluster2/ca-key.pem  --from-file=cluster2/root-cert.pem   --from-file=cluster2/cert-chain.pem

kubectl --context istio-3 create secret generic cacerts -n istio-system  --from-file=cluster3/ca-cert.pem  --from-file=cluster3/ca-key.pem  --from-file=cluster3/root-cert.pem   --from-file=cluster3/cert-chain.pem
popd

# Install Istio with ew-gw on all three clusters
export ISTIO_DIR=/home/solo/dev/istio/istio-1.12.1
istioctl install -y --context istio-1 -f ./istio/cluster1.yaml
istioctl install -y --context istio-1 -f ./istio/ew-gateway1.yaml
kubectl --context=istio-1 apply -n istio-system -f ./istio/expose-services.yaml

istioctl install -y --context istio-2 -f ./istio/cluster2.yaml
istioctl install -y --context istio-2 -f ./istio/ew-gateway2.yaml
kubectl --context=istio-2 apply -n istio-system -f ./istio/expose-services.yaml

istioctl install -y --context istio-3 -f ./istio/cluster3.yaml
istioctl install -y --context istio-3 -f ./istio/ew-gateway3.yaml
kubectl --context=istio-3 apply -n istio-system -f ./istio/expose-services.yaml

# Set up Endpoint Discovery
istioctl x create-remote-secret  --context=istio-2 --name=cluster2 | kubectl apply -f - --context=istio-1
istioctl x create-remote-secret  --context=istio-3 --name=cluster3 | kubectl apply -f - --context=istio-1

istioctl x create-remote-secret  --context=istio-1 --name=cluster1  | kubectl apply -f - --context=istio-2
istioctl x create-remote-secret  --context=istio-3 --name=cluster3 | kubectl apply -f - --context=istio-2

istioctl x create-remote-secret  --context=istio-1 --name=cluster1 | kubectl apply -f - --context=istio-3
istioctl x create-remote-secret  --context=istio-2 --name=cluster2 | kubectl apply -f - --context=istio-3