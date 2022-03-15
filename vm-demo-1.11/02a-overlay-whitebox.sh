. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD


source ./env.sh


echo "ISTIO_META_AUTO_REGISTER_GROUP=python-http" >> "${WORK_DIR}"/files/sidecar.env
echo "ISTIO_SVC_IP=$LOCAL_VM_IP" >> "${WORK_DIR}"/files/sidecar.env

# for whitebox mode
#ISTIO_CUSTOM_IP_TABLES=true >> ??
#ISTIO_META_INTERCEPTION_MODE=NONE >> ??
# 
