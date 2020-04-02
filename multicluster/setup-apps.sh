
. ./env.sh

# Install on Cluster 1
kubectl --context $CLUSTER_1 create namespace foo
kubectl --context $CLUSTER_1 label namespace foo istio-injection=enabled
kubectl --context $CLUSTER_1 apply -n foo -f resources/k8s/sleep.yaml



# Install on Cluster 1    
kubectl --context $CLUSTER_2 create namespace bar
kubectl --context $CLUSTER_2 label namespace bar istio-injection=enabled
kubectl --context $CLUSTER_2 apply -n bar -f resources/k8s/httpbin.yaml

