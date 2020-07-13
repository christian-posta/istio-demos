
BASE="./certs"
ROOTA_DIR="$BASE/ROOTA"
ROOTB_DIR="$BASE/ROOTB"
INTERMEDIATE_A="$BASE/intermediate-rootA"
INTERMEDIATE_A2="$BASE/intermediate-rootA2"
INTERMEDIATE_B="$BASE/intermediate-rootB"
CURRENT_ISTIO="$BASE/current-istio"

mkdir -p $CURRENT_ISTIO

mkdir -p $ROOTA_DIR
STEPPATH="$ROOTA_DIR" step ca init --pki --name "ROOT-A CA" --provisioner "ceposta@example.org" --password-file ./resources/pwfile

mkdir -p ./certs/ROOTB
STEPPATH="$ROOTB_DIR" step ca init --pki --name "ROOT-B CA" --provisioner "ceposta@example.org" --password-file ./resources/pwfile

mkdir -p "$INTERMEDIATE_A"
cp "$ROOTA_DIR/certs/root_ca.crt" "$INTERMEDIATE_A/root-cert.pem"
step certificate create istio-intermediate-ca-A "$INTERMEDIATE_A/ca-cert.pem" "$INTERMEDIATE_A/ca-key.pem" --profile intermediate-ca --kty RSA --ca "$ROOTA_DIR/certs/root_ca.crt" --ca-key "$ROOTA_DIR/secrets/root_ca_key" --no-password --insecure
step certificate bundle "$INTERMEDIATE_A/ca-cert.pem" "$INTERMEDIATE_A/root-cert.pem" "$INTERMEDIATE_A/cert-chain.pem"


mkdir -p "$INTERMEDIATE_A2"
cp "$ROOTA_DIR/certs/root_ca.crt" "$INTERMEDIATE_A2/root-cert.pem"
step certificate create istio-intermediate-ca-A2 "$INTERMEDIATE_A2/ca-cert.pem" "$INTERMEDIATE_A2/ca-key.pem" --profile intermediate-ca --kty RSA --ca "$ROOTA_DIR/certs/root_ca.crt" --ca-key "$ROOTA_DIR/secrets/root_ca_key" --no-password --insecure
step certificate bundle "$INTERMEDIATE_A2/ca-cert.pem" "$INTERMEDIATE_A2/root-cert.pem" "$INTERMEDIATE_A2/cert-chain.pem"

mkdir -p "$INTERMEDIATE_B"
cp "$ROOTB_DIR/certs/root_ca.crt" "$INTERMEDIATE_B/root-cert.pem"
step certificate create istio-intermediate-ca-B "$INTERMEDIATE_B/ca-cert.pem" "$INTERMEDIATE_B/ca-key.pem" --profile intermediate-ca --kty RSA --ca "$ROOTB_DIR/certs/root_ca.crt" --ca-key "$ROOTB_DIR/secrets/root_ca_key" --no-password --insecure
step certificate bundle "$INTERMEDIATE_B/ca-cert.pem" "$INTERMEDIATE_B/root-cert.pem" "$INTERMEDIATE_B/cert-chain.pem"

mkdir -p ./certs/multiple-rootCA
cp "$ROOTA_DIR/certs/root_ca.crt" "./certs/multiple-rootCA/root-cert.pem"
cat "$ROOTB_DIR/certs/root_ca.crt" >> "./certs/multiple-rootCA/root-cert.pem"


echo "verifying everything looks good"

. ./verify-certs.sh


echo "set up sample services"
istioctl kube-inject -f ./resources/sleep.yaml | kubectl apply -f -
istioctl kube-inject -f ./resources/httpbin.yaml | kubectl apply -f -


echo "remove the hpa for istiod"
kubectl delete -n istio-system hpa/istiod 

echo "Turning mTLS to strict"
kubectl apply -f resources/default-peerauth.yaml -n istio-system