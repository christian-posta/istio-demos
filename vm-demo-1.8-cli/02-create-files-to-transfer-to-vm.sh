. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


source ./env.sh

rm -fr ${WORK_DIR}
mkdir -p ${WORK_DIR}


cp resources/prep-vm.sh ${WORK_DIR}
cp resources/clean-vm.sh ${WORK_DIR}
cp resources/start-istio.sh ${WORK_DIR}
cp resources/stop-istio.sh ${WORK_DIR}
cp resources/tail-istio-log.sh ${WORK_DIR}
cp resources/run-http.sh ${WORK_DIR}
cp resources/index.html ${WORK_DIR}

# enable this once they fix https://github.com/istio/istio/issues/29151
#istioctl1.8 x workload group create --name "${VM_APP}" --namespace "${VM_NAMESPACE}" --labels app="${VM_APP}" --serviceAccount "${SERVICE_ACCOUNT}" > ${WORK_DIR}/workloadgroup.yaml

# for auto registration
desc "Creat workloadgroup.yaml"
run "cat resources/workloadgroup.yaml"
run "kubectl -n ${VM_NAMESPACE} apply -f resources/workloadgroup.yaml"

desc "Create files"
run "istioctl1.8 x workload entry configure -f resources/workloadgroup.yaml -o "${WORK_DIR}/files" --autoregister"

touch "${WORK_DIR}"/sidecar.env
echo "ISTIO_META_AUTO_REGISTER_GROUP=python-http" >> "${WORK_DIR}"/files/sidecar.env