
. ./env.sh

kubectl create --context="${CTX_CLUSTER1}" namespace sample
kubectl create --context="${CTX_CLUSTER2}" namespace sample

kubectl label --context="${CTX_CLUSTER1}" namespace sample istio-injection=enabled
kubectl label --context="${CTX_CLUSTER2}" namespace sample istio-injection=enabled

kubectl apply --context="${CTX_CLUSTER1}" -f resources/k8s/helloworld.yaml -l service=helloworld -n sample
kubectl apply --context="${CTX_CLUSTER2}" -f resources/k8s/helloworld.yaml -l service=helloworld -n sample

kubectl apply --context="${CTX_CLUSTER1}" -f resources/k8s/helloworld.yaml -l version=v1 -n sample
kubectl apply --context="${CTX_CLUSTER2}" -f resources/k8s/helloworld.yaml -l version=v2 -n sample

kubectl apply --context="${CTX_CLUSTER1}" -f resources/k8s/sleep.yaml -n sample
kubectl apply --context="${CTX_CLUSTER2}" -f resources/k8s/sleep.yaml -n sample