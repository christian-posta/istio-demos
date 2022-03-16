. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


source ./env.sh



kubectl -n ${VM_NAMESPACE} apply -f resources/istio/sidecar-whitebox-vm.yaml


