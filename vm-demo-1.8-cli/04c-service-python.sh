source env.sh

cat <<EOF | kubectl -n "${VM_NAMESPACE}" apply -f -
apiVersion: v1
kind: Service
metadata:
  name: python-http
  labels:
    app: python-http
spec:
  ports:
  - port: 9090
    name: http-vm
    targetPort: 9090
  selector:
    app: python-http
EOF
