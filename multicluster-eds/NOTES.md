
# how should istio be installed?
We are using revisions starting with Lab01... will need to think about how that transitions through the previous labs (3, 4, etc)

For now, just using basic install with clusterX.yaml

(note, these methods install the ingress gateway and the control plane into same namespace... we will want to walk people through east-west gateway installation most likely.....)

istioctl install -y --context=istio-1 -f cluster1.yaml
istioctl install -y --context=istio-2 -f cluster2.yaml
istioctl install -y --context=istio-3 -f cluster3.yaml

# Set up secrets for all 3 clusters
kubectl create secret generic cacerts -n istio-system --from-file=cluster1/ca-cert.pem --from-file=cluster1/ca-key.pem --from-file=cluster1/root-cert.pem  --from-file=cluster1/cert-chain.pem

kubectl --context istio-2 create secret generic cacerts -n istio-system   --from-file=cluster2/ca-cert.pem       --from-file=cluster2/ca-key.pem  --from-file=cluster2/root-cert.pem   --from-file=cluster2/cert-chain.pem

kubectl --context istio-3 create secret generic cacerts -n istio-system  --from-file=cluster3/ca-cert.pem  --from-file=cluster3/ca-key.pem  --from-file=cluster3/root-cert.pem   --from-file=cluster3/cert-chain.pem



# enable endpoint discovery
istioctl x create-remote-secret  --context=istio-2 --name=cluster2 | kubectl apply -f - --context=istio-1
istioctl x create-remote-secret  --context=istio-3 --name=cluster3 | kubectl apply -f - --context=istio-1

istioctl x create-remote-secret  --context=istio-1 --name=cluster1 | kubectl apply -f - --context=istio-2
istioctl x create-remote-secret  --context=istio-3 --name=cluster3 | kubectl apply -f - --context=istio-2

istioctl x create-remote-secret  --context=istio-1 --name=cluster1 | kubectl apply -f - --context=istio-3
istioctl x create-remote-secret  --context=istio-2 --name=cluster2 | kubectl apply -f - --context=istio-3

# create east-west gateways
export ISTIO_DIR=/home/solo/dev/istio/istio-1.12.1

kubectl --context=istio-1 label namespace istio-system topology.istio.io/network=network1
kubectl --context=istio-2 label namespace istio-system topology.istio.io/network=network2
kubectl --context=istio-3 label namespace istio-system topology.istio.io/network=network3

# generate ew-gateways (when automating, let's just use the generated yamls)
$ISTIO_DIR/samples/multicluster/gen-eastwest-gateway.sh --mesh mesh1 --cluster cluster1 --network network1 > /home/solo/dev/workshop/ew-gateway1.yaml
$ISTIO_DIR/samples/multicluster/gen-eastwest-gateway.sh --mesh mesh1 --cluster cluster2 --network network2 > /home/solo/dev/workshop/ew-gateway2.yaml
$ISTIO_DIR/samples/multicluster/gen-eastwest-gateway.sh --mesh mesh1 --cluster cluster3 --network network3 > /home/solo/dev/workshop/ew-gateway3.yaml

kubectl --context=istio-1 apply -n istio-system -f $ISTIO_DIR/samples/multicluster/expose-services.yaml
kubectl --context=istio-2 apply -n istio-system -f $ISTIO_DIR/samples/multicluster/expose-services.yaml
kubectl --context=istio-3 apply -n istio-system -f $ISTIO_DIR/samples/multicluster/expose-services.yaml


# to verify, we will install some of the istio samples

* note, we may want to use revisions...

kubectl --context istio-1 create ns sample
kubectl --context istio-2 create ns sample
kubectl --context istio-3 create ns sample

kubectl label --context=istio-1 namespace sample istio-injection=enabled
kubectl label --context=istio-2 namespace sample istio-injection=enabled
kubectl label --context=istio-3 namespace sample istio-injection=enabled

export ISTIO_DIR=/home/solo/dev/istio/istio-1.12.1
kubectl apply --context=istio-1 -f $ISTIO_DIR/samples/helloworld/helloworld.yaml -l service=helloworld -n sample
kubectl apply --context=istio-2 -f $ISTIO_DIR/samples/helloworld/helloworld.yaml -l service=helloworld -n sample
kubectl apply --context=istio-3 -f $ISTIO_DIR/samples/helloworld/helloworld.yaml -l service=helloworld -n sample


kubectl apply --context=istio-1 -f $ISTIO_DIR/samples/helloworld/helloworld.yaml -l version=v1 -n sample
kubectl apply --context=istio-2 -f $ISTIO_DIR/samples/helloworld/helloworld.yaml -l version=v1 -n sample
kubectl apply --context=istio-3 -f $ISTIO_DIR/samples/helloworld/helloworld.yaml -l version=v2 -n sample


kubectl apply --context=istio-1 -f $ISTIO_DIR/samples/sleep/sleep.yaml -n sample
kubectl apply --context=istio-2 -f $ISTIO_DIR/samples/sleep/sleep.yaml -n sample
kubectl apply --context=istio-3 -f $ISTIO_DIR/samples/sleep/sleep.yaml -n sample



