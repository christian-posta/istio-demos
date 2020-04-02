. ./env.sh

# Install on Cluster 1
istioctl --context $CLUSTER_1 manifest generate -f resources/istio/values-istio-multicluster-gateways.yaml | kubectl delete -f -
kubectl --context $CLUSTER_1 delete namespace istio-system


# Install on Cluster 1    
istioctl --context $CLUSTER_2 manifest generate -f resources/istio/values-istio-multicluster-gateways.yaml | kubectl delete -f -
kubectl --context $CLUSTER_2 delete namespace istio-system