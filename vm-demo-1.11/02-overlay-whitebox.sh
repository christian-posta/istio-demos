source ./env.sh


# for whitebox mode
echo "ISTIO_CUSTOM_IP_TABLES=true" >> "${WORK_DIR}"/files/sidecar.env
echo "ISTIO_META_INTERCEPTION_MODE=NONE" >> "${WORK_DIR}"/files/sidecar.env
echo "ISTIO_INBOUND_INTERCEPTION_MODE=NONE" >> "${WORK_DIR}"/files/sidecar.env

 
