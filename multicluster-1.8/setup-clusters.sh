
. ./env.sh

# Install on Cluster 1
kubectl --context $CLUSTER_1 create namespace istio-system
kubectl --context $CLUSTER_1 create secret generic cacerts -n istio-system \
    --from-file=resources/certs/ca-cert.pem \
    --from-file=resources/certs/ca-key.pem \
    --from-file=resources/certs/root-cert.pem \
    --from-file=resources/certs/cert-chain.pem
kubectl --context="${CTX_CLUSTER1}" get namespace istio-system && \
  kubectl --context="${CTX_CLUSTER1}" label namespace istio-system topology.istio.io/network=network1

istioctl1.8 install -y --context="${CTX_CLUSTER1}" -f resources/istio/cluster1-operator.yaml
istioctl1.8 install -y --context="${CTX_CLUSTER1}" -f resources/istio/cluster1-ewgw-operator.yaml
kubectl --context="${CTX_CLUSTER1}" apply -f resources/istio/expose-services.yaml



# Install on Cluster 2
kubectl --context $CLUSTER_2 create namespace istio-system
kubectl --context $CLUSTER_2 create secret generic cacerts -n istio-system \
    --from-file=resources/certs/ca-cert.pem \
    --from-file=resources/certs/ca-key.pem \
    --from-file=resources/certs/root-cert.pem \
    --from-file=resources/certs/cert-chain.pem
kubectl --context="${CTX_CLUSTER2}" get namespace istio-system && \
  kubectl --context="${CTX_CLUSTER2}" label namespace istio-system topology.istio.io/network=network2    

istioctl1.8 install -y --context="${CTX_CLUSTER2}" -f resources/istio/cluster2-operator.yaml
istioctl1.8 install -y --context="${CTX_CLUSTER2}" -f resources/istio/cluster2-ewgw-operator.yaml
kubectl --context="${CTX_CLUSTER2}" apply -f resources/istio/expose-services.yaml