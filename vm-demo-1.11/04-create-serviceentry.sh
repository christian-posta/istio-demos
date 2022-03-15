. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


source ./env.sh



kubectl -n ${VM_NAMESPACE} apply -f resources/istio/vmservice-serviceentry.yaml

#desc "Verify this service made it into istios service registry"
#run "kubectl exec -it deploy/sleep -- curl localhost:15000/clusters | grep vmservice"
