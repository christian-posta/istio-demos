source env.sh

cat <<EOF | kubectl -n "${VM_NAMESPACE}" apply -f -
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: vm-workload-svc
spec:
  hosts:
  - vmservice.example.com
  location: MESH_INTERNAL
  ports:
  - number: 80
    name: http
    protocol: HTTP
    targetPort: 9090
  resolution: STATIC
  workloadSelector:
    labels:
      app: cloud-vm
EOF

