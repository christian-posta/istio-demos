# Assume that we have Istio installed on all the three clusters

kubectl --context istio-1 create ns sample
kubectl --context istio-2 create ns sample
kubectl --context istio-3 create ns sample

kubectl label --context=istio-1 namespace sample istio-injection=enabled
kubectl label --context=istio-2 namespace sample istio-injection=enabled
kubectl label --context=istio-3 namespace sample istio-injection=enabled

export ISTIO_DIR=/home/solo/dev/istio/istio-1.12.1
kubectl apply --context=istio-1 -f ./istio/helloworld.yaml -l service=helloworld -n sample
kubectl apply --context=istio-2 -f ./istio/helloworld.yaml -l service=helloworld -n sample
kubectl apply --context=istio-3 -f ./istio/helloworld.yaml -l service=helloworld -n sample


kubectl apply --context=istio-1 -f ./istio/helloworld.yaml -l version=v1 -n sample
kubectl apply --context=istio-2 -f ./istio/helloworld.yaml -l version=v1 -n sample
kubectl apply --context=istio-3 -f ./istio/helloworld.yaml -l version=v2 -n sample


kubectl apply --context=istio-1 -f ./istio/sleep.yaml -n sample
kubectl apply --context=istio-2 -f ./istio/sleep.yaml -n sample
kubectl apply --context=istio-3 -f ./istio/sleep.yaml -n sample