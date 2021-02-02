. ./env.sh

# Install on Cluster 1
istioctl --context $CLUSTER_1 x uninstall -y --purge
kubectl --context $CLUSTER_1 delete namespace istio-system


# Install on Cluster 1    
istioctl --context $CLUSTER_2 x uninstall -y --purge
kubectl --context $CLUSTER_2 delete namespace istio-system