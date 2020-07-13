BASE="./certs"
ROOTA_DIR="$BASE/ROOTA"
ROOTB_DIR="$BASE/ROOTB"
INTERMEDIATE_A="$BASE/intermediate-rootA"
INTERMEDIATE_A2="$BASE/intermediate-rootA2"
INTERMEDIATE_B="$BASE/intermediate-rootB"
CURRENT_ISTIO="$BASE/current-istio"

# get the root-cert from cm in default and compare to what istio wrote to cm in istio-system
kubectl get cm istio-ca-root-cert -n default -o jsonpath="{.data['root-cert\.pem']}" > $CURRENT_ISTIO/istio-ca-root-cert-cm

kubectl get cm -n istio-system istio-security -o jsonpath="{.data['caTLSRootCert']}" | step base64 -d > $CURRENT_ISTIO/istio-security-cm

kubectl get mutatingwebhookconfiguration istio-sidecar-injector -o jsonpath="{.webhooks[*].clientConfig.caBundle}" | step base64 -d > $CURRENT_ISTIO/injector-ca

kubectl get validatingwebhookconfiguration istiod-istio-system -o jsonpath="{.webhooks[*].clientConfig.caBundle}" | step base64 -d > $CURRENT_ISTIO/istiod-validation-ca

echo "Using Dir? '$1'"

if [ -z "$1" ]; then
    echo "checking default cms"
    diff $CURRENT_ISTIO/istio-ca-root-cert-cm $CURRENT_ISTIO/istio-security-cm
else
    DIR=$1
    echo "checking that the root certs in CM are updated and in sync..."
    diff $DIR/root-cert.pem $CURRENT_ISTIO/istio-ca-root-cert-cm
    echo "checking that the chain is the same in "
    diff $DIR/cert-chain.pem $CURRENT_ISTIO/istio-security-cm
fi


echo "checking injector webhook CA"
diff $CURRENT_ISTIO/istio-ca-root-cert-cm $CURRENT_ISTIO/injector-ca

echo "checking validation webhook CA"
diff $CURRENT_ISTIO/istio-ca-root-cert-cm $CURRENT_ISTIO/istiod-validation-ca

echo "Here's the current root CA"
cat $CURRENT_ISTIO/istio-ca-root-cert-cm
read -s