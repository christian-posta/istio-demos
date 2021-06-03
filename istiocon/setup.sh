# should already have our sample apps set up    
kubectl create ns istioinaction
kubectl -n istioinaction apply -f ../sample-apps/web-api.yaml
kubectl -n istioinaction apply -f ../sample-apps/recommendation.yaml
kubectl -n istioinaction apply -f ../sample-apps/purchase-history-v1.yaml
kubectl -n istioinaction apply -f ../sample-apps/sleep.yaml
kubectl -n default apply -f ../sample-apps/sleep.yaml



kubectl create ns vault
helm install vault hashicorp/vault --set "server.dev.enabled=true" -n vault

echo "take a rest to let vault come up"
sleep 5s

pushd ./resources/vault-istiod
./init-ca-in-pod.sh
popd