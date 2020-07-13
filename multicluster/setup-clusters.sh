
. ./env.sh

# Install on Cluster 1
kubectl --context $CLUSTER_1 create namespace istio-system
kubectl --context $CLUSTER_1 create secret generic cacerts -n istio-system \
    --from-file=resources/certs/ca-cert.pem \
    --from-file=resources/certs/ca-key.pem \
    --from-file=resources/certs/root-cert.pem \
    --from-file=resources/certs/cert-chain.pem
istioctl --context $CLUSTER_1 manifest apply -f resources/istio/values-istio-multicluster-gateways.yaml    

kubectl --context $CLUSTER_1 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"global": ["$(kubectl --context $CLUSTER_1 get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
EOF





# Install on Cluster 1    
kubectl --context $CLUSTER_2 create namespace istio-system
kubectl --context $CLUSTER_2 create secret generic cacerts -n istio-system \
    --from-file=resources/certs/ca-cert.pem \
    --from-file=resources/certs/ca-key.pem \
    --from-file=resources/certs/root-cert.pem \
    --from-file=resources/certs/cert-chain.pem
istioctl --context $CLUSTER_2 manifest apply -f resources/istio/values-istio-multicluster-gateways.yaml    
kubectl --context $CLUSTER_2 apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"global": ["$(kubectl --context $CLUSTER_2 get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})"]}
EOF
