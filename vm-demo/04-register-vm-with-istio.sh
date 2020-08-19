source env.sh

VM_IP=$(gcloud compute instances describe --zone "us-west1-b" "ceposta-linux-builds" --project "solo-public" --format='get(networkInterfaces[0].networkIP)')

cat <<EOF | kubectl -n "${VM_NAMESPACE}" apply -f -
apiVersion: v1
kind: Service
metadata:
  name: cloud-vm
  labels:
    app: cloud-vm
spec:
  ports:
  - port: 7070
    name: grpc
  - port: 8090
    name: http
  selector:
    app: cloud-vm
EOF


cat <<EOF | kubectl -n "${VM_NAMESPACE}" apply -f -
  apiVersion: networking.istio.io/v1beta1
  kind: WorkloadEntry
  metadata:
    name: "${VM_NAME}"
    namespace: "${VM_NAMESPACE}"
  spec:
    address: "${VM_IP}"
    labels:
      app: gce-vm
    serviceAccount: "${SERVICE_ACCOUNT}"
EOF