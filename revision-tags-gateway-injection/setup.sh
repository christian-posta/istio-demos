istioctl1.9 install -y --set profile=minimal

pushd ../sample-apps
kubectl create ns istioinaction
kubectl label namespace istioinaction istio-injection=enabled --overwrite
kubectl apply -n istioinaction -f web-api.yaml
kubectl apply -n istioinaction -f recommendation.yaml
kubectl apply -n istioinaction -f purchase-history-v1.yaml
kubectl apply -n istioinaction -f sleep.yaml
kubectl apply -n default -f sleep.yaml

kubectl create ns sample-ns
kubectl apply -n sample-ns -f sleep.yaml
popd

