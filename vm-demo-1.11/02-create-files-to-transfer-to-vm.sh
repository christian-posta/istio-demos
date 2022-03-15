. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


source ./env.sh

rm -fr ${WORK_DIR}
mkdir -p ${WORK_DIR}


cp resources/package/prep-vm.sh ${WORK_DIR}
cp resources/package/clean-vm.sh ${WORK_DIR}
cp resources/package/start-istio.sh ${WORK_DIR}
cp resources/package/stop-istio.sh ${WORK_DIR}
cp resources/package/tail-istio-log.sh ${WORK_DIR}
cp resources/package/run-http.sh ${WORK_DIR}
cp resources/package/index.html ${WORK_DIR}

# for auto registration

kubectl -n ${VM_NAMESPACE} apply -f resources/istio/workloadgroup.yaml

istioctl1.11 x workload entry configure -f resources/istio/workloadgroup.yaml -o "${WORK_DIR}/files" --clusterID "${CLUSTER_ID}" --autoregister

touch "${WORK_DIR}"/files/sidecar.env
echo "ISTIO_META_AUTO_REGISTER_GROUP=python-http" >> "${WORK_DIR}"/files/sidecar.env

LOCAL_VM_IP=$(gcloud compute instances describe $VM_NAME --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --project "solo-public")

echo "ISTIO_SVC_IP=$LOCAL_VM_IP" >> "${WORK_DIR}"/files/sidecar.env