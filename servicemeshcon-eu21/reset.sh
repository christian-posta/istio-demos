kubectl label namespace istioinaction istio-injection-
kubectl delete deploy/web-api-canary  -n istioinaction

istioctl x uninstall -y --purge
kubectl delete ns istio-system

kubectl -n istioinaction rollout restart deploy/web-api
kubectl -n istioinaction rollout restart deploy/recommendation
kubectl -n istioinaction rollout restart deploy/purchase-history-v1
kubectl -n istioinaction rollout restart deploy/sleep