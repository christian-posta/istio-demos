source env.sh

VM_IP=$(gcloud compute instances describe --zone "us-west1-b" "ceposta-linux-builds" --project "solo-public" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')


cat <<EOF | kubectl -n "${VM_NAMESPACE}" apply -f -
apiVersion: v1
kind: Service
metadata:
  name: cloud-vm
  labels:
    app: cloud-vm
spec:
  ports:
  - port: 8080
    name: http-vm
    targetPort: 9090
  selector:
    app: cloud-vm
EOF

echo "Waiting for the Service to be created..."
sleep 3s

echo "Now creating the WorkloadEntry"
cat <<EOF | kubectl -n "${VM_NAMESPACE}" apply -f -
  apiVersion: networking.istio.io/v1beta1
  kind: WorkloadEntry
  metadata:
    name: "${VM_NAME}"
    namespace: "${VM_NAMESPACE}"
  spec:
    address: "${VM_IP}"
    labels:
      app: cloud-vm
    serviceAccount: "${SERVICE_ACCOUNT}"
EOF