. ./env.sh

# Install on Cluster 1
kubectl --context $CLUSTER_1 delete namespace foo



# Install on Cluster 1    
kubectl --context $CLUSTER_2 delete namespace bar
