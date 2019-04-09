kubectl delete sidecar -n default default
kubectl delete ns $(k get ns | grep ^[s]| awk '{print $1}')
kubectl get ns -w
./purge-bookinfo-mem.sh 