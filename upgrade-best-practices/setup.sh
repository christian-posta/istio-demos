# we are going with 3 replicas of the istio control plane istiod
# deploy minimal profile, no ingress gateway, we'll do that separately
istioctl1.9 install -y --set profile=minimal --revision 1-9-5 --set components.pilot.k8s.replicaCount=3

pushd ../sample-apps
kubectl create ns istioinaction
kubectl label namespace istioinaction istio.io/rev=1-9-5 --overwrite
kubectl apply -n istioinaction -f web-api.yaml
kubectl apply -n istioinaction -f recommendation.yaml
kubectl apply -n istioinaction -f purchase-history-v1.yaml
kubectl apply -n istioinaction -f sleep.yaml
kubectl apply -n default -f sleep.yaml
popd

