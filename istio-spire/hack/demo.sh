
# create namespace
kubectl apply -f resources/spire-namespace.yaml

# spire needs to update it's server cert, need service account, rbac, etc
kubectl apply \
    -f resources/server-account.yaml \
    -f resources/spire-bundle-configmap.yaml \
    -f resources/server-cluster-role.yaml


# deploy the server and configmap
kubectl apply \
    -f resources/server-configmap.yaml \
    -f resources/server-statefulset.yaml \
    -f resources/server-service.yaml


# deploy agents as a daemonset; agent needs read access to k8s cluster to perform node
# attestation
kubectl apply \
    -f resources/agent-account.yaml \
    -f resources/agent-cluster-role.yaml
kubectl apply \
    -f resources/agent-configmap.yaml \
    -f resources/agent-daemonset.yaml    


# register the agent/node
kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s_sat:cluster:demo-cluster \
    -selector k8s_sat:agent_ns:spire \
    -selector k8s_sat:agent_sa:spire-agent \
    -node


# specify an entry for a workload referencing the default SA
kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/default/sa/default \
    -parentID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s:ns:default \
    -selector k8s:sa:default

# create a sample workload in default namespace

kubectl apply -f resources/client-deployment.yaml



