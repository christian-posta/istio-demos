# install istio 1.10

# set up cert manager
kubectl create namespace cert-manager
kubectl create namespace istio-system
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.2.0 --create-namespace --set installCRDs=true

kubectl -n cert-manager rollout status deploy/cert-manager
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector
kubectl -n cert-manager rollout status deploy/cert-manager-webhook

# create root certs to use for signing/CA
kubectl create -n cert-manager secret tls cert-manager-cacerts --cert resources/certs/root-ca.crt --key resources/certs/root-ca.key


max=15

for x in $(seq 1 $max); do
    kubectl apply -f resources/ca-bootstrap.yaml
    res=$?

    if [ $res -eq 0 ]; then
        break
    fi

    echo ">> [${x}] cert-manager not ready" && sleep 5

    if [ x -eq 15 ]; then
        echo ">> Failed to deploy cert-manager and bootstrap manifests in time"
        exit 1
    fi
done


# install istio-csr
helm install -n cert-manager cert-manager-istio-csr jetstack/cert-manager-istio-csr -f resources/istio-csr-values.yaml

kubectl -n cert-manager rollout status deploy/cert-manager-istio-csr

echo "Press ENTER to install Istio (is the istiod-tls cert there?"

# install istio
istioctl1.10 install -y -f resources/istio-operator.yaml
kubectl apply -f resources/default-peerauth-strict.yaml