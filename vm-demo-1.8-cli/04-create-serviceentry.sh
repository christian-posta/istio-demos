. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


source ./env.sh

desc "Creat serviceentry"
run "cat resources/vmservice-serviceentry.yaml"
run "kubectl -n ${VM_NAMESPACE} apply -f resources/vmservice-serviceentry.yaml"

desc "Verify this service made it into istios service registry"
run "kubectl exec -it deploy/sleep -- curl localhost:15000/clusters | grep vmservice"
