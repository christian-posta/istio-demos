# should already have our sample apps set up    
kubectl create ns istioinaction
kubectl -n istioinaction apply -f ../sample-apps/web-api.yaml
kubectl -n istioinaction apply -f ../sample-apps/recommendation.yaml
kubectl -n istioinaction apply -f ../sample-apps/purchase-history-v1.yaml
kubectl -n istioinaction apply -f ../sample-apps/sleep.yaml
