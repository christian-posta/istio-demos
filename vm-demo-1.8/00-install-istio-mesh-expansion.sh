source env.sh

kubectl create ns istio-system

# we want to enable the DNS capture 
istioctl1.8 install -y --set profile=preview
cat ~/dev/istio/latest-1.8/samples/multicluster/expose-istiod.yaml | sed 's/eastwestgateway/ingressgateway/' | kubectl apply -f -


