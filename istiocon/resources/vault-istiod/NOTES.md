
# Install Helm
helm repo add hashicorp https://helm.releases.hashicorp.com
kubectl create ns vault
helm install vault hashicorp/vault --set "server.dev.enabled=true" -n vault



# enable the certs
vault auth enable kubernetes

vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/gen-int-ca-istio bound_service_account_names=istiod-service-account bound_service_account_namespaces=istio-system  policies=gen-int-ca-istio ttl=2400h


vault secrets enable pki

vault write -format=json pki/root/generate/internal common_name="pki-ca-root" ttl=187600h

vault secrets enable -path pki_int pki

## policy
vault policy write gen-int-ca-istio - <<EOF
path "pki_int/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "pki/cert/ca" {
  capabilities = ["read"]
}
path "pki/root/sign-intermediate" {
  capabilities = ["create", "read", "update", "list"]
}
EOF


### init container

just deploy the new istiod-deploy.yaml that has been configured to use the 1-8-3 revision (sidecar injector cm and istiod cm)


#! /bin/bash
set -euo pipefail
export VAULT_TOKEN=$(vault write -field=token -address="http://vault.vault.svc.cluster.local:8200" \
  auth/kubernetes/login role=gen-int-ca-istio jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token))
vault write -address="http://vault.vault.svc.cluster.local:8200" \
  -format=json pki_int/intermediate/generate/exported \
  common_name="myvault.com Intermediate Authority" ttl=43800h | tee \
  >(jq -r .data.csr > /etc/cacerts/ca-cert.csr) \
  >(jq -r .data.private_key > /etc/cacerts/ca-key.pem)
vault write -format=json -address="http://vault.vault.svc.cluster.local:8200" pki/root/sign-intermediate \
  csr=@/etc/cacerts/ca-cert.csr format=pem_bundle ttl=43800h | tee \
  >(jq -r .data.certificate > /etc/cacerts/ca-cert.pem) \
  >(jq -r .data.issuing_ca > /etc/cacerts/root-cert.pem)
cat /etc/cacerts/ca-cert.pem /etc/cacerts/root-cert.pem > /etc/cacerts/cert-chain.pem