source env.sh

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
