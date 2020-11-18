source env.sh

mkdir -p "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"

cp resources/prep-vm.sh ./work
cp resources/clean-vm.sh ./work
cp resources/start-istio.sh ./work
cp resources/stop-istio.sh ./work
cp resources/tail-istio-log.sh ./work
cp resources/run-http.sh ./work
cp resources/index.html ./work

# Get short lived token
tokenexpiretime=3600
echo '{"kind":"TokenRequest","apiVersion":"authentication.k8s.io/v1","spec":{"audiences":["istio-ca"],"expirationSeconds":'$tokenexpiretime'}}' | kubectl create --raw /api/v1/namespaces/$VM_NAMESPACE/serviceaccounts/$SERVICE_ACCOUNT/token -f - | jq -j '.status.token' > "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/istio-token

# get root ca
kubectl -n "${VM_NAMESPACE}" get configmaps -n istio-system istio-ca-root-cert -o json | jq -j '."data"."root-cert.pem"' > "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/root-cert.pem

# create cluster.env
ISTIO_SERVICE_CIDR=$(echo '{"apiVersion":"v1","kind":"Service","metadata":{"name":"tst"},"spec":{"clusterIP":"1.1.1.1","ports":[{"port":443}]}}' | kubectl apply -f - 2>&1 | sed 's/.*valid IPs is //')
touch "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/cluster.env
echo ISTIO_SERVICE_CIDR=$ISTIO_SERVICE_CIDR > "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/cluster.env
echo "ISTIO_INBOUND_PORTS=9090" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/cluster.env

echo "ISTIO_NAMESPACE=$VM_NAMESPACE" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/cluster.env

# Set the IP address to the ingress gateway
INGRESS_HOST=$(kubectl get svc -n istio-system | grep ingressgateway | awk '{print $4}')
touch "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/hosts-addendum
echo "${INGRESS_HOST} istiod.istio-system.svc" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/hosts-addendum
ISTIO_SERVICE_IP_STUB=$(echo $ISTIO_SERVICE_CIDR | cut -f1 -d"/")

# Set up DNS files:
echo $(cat resources/dns/dnsmasq.conf | sed  s/{ISTIO_SERVICE_IP_STUB}/$ISTIO_SERVICE_IP_STUB/) >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/dnsmasq-snippet.conf

cp resources/dns/resolved.conf "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/resolved.conf

# create sidecar.env
touch "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
echo "ISTIO_INBOUND_PORTS=*" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
echo "ISTIO_LOCAL_EXCLUDE_PORTS=15090,15021,15020" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
echo "PROV_CERT=/var/run/secrets/istio" >>"${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
echo "OUTPUT_CERTS=/var/run/secrets/istio" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
echo "ISTIO_META_NETWORK=vm-network" >> "${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
# Clearn out the PROV_CERT, istio 1.8 doesn't like it
# https://github.com/istio/istio/pull/28827
echo "PROV_CERT=" >>"${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env

# Use DNS capture
echo "ISTIO_META_DNS_CAPTURE=true" >>"${WORK_DIR}"/"${CLUSTER_NAME}"/"${VM_NAMESPACE}"/sidecar.env
