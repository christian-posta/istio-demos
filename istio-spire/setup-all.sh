#!/bin/bash

# Install Spire server
echo "Installing Spire server...ENTER to continue"
read -s
kubectl apply -f resources/spire-quickstart.yaml

echo "Waiting for spire namespace..."
./scripts/check.sh istio-1 spire


# Install Istio with Spire stuffs
echo "Installing Istio...ENTER to continue"
read -s

istioctl install --skip-confirmation -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
spec:
  profile: default
  meshConfig:
    trustDomain: example.org
  values:
    global:
    # This is used to customize the sidecar template
    sidecarInjectorWebhook:
      templates:
        spire: |
          spec:
            containers:
            - name: istio-proxy
              volumeMounts:
              - name: workload-socket
                mountPath: /run/secrets/workload-spiffe-uds
                readOnly: true
            volumes:
              - name: workload-socket
                csi:
                  driver: "csi.spiffe.io"
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        label:
          istio: ingressgateway
        k8s:
          overlays:
            - apiVersion: apps/v1
              kind: Deployment
              name: istio-ingressgateway
              patches:
                - path: spec.template.spec.volumes.[name:workload-socket]
                  value:
                    name: workload-socket
                    csi:
                      driver: "csi.spiffe.io"
                - path: spec.template.spec.containers.[name:istio-proxy].volumeMounts.[name:workload-socket]
                  value:
                    name: workload-socket
                    mountPath: "/run/secrets/workload-spiffe-uds"
                    readOnly: true
EOF

echo "Waiting for istio-system namespace..."
./scripts/check.sh istio-1 istio-system

echo "Register workloads... ENTER to continue"
read -s
# Register workloads
INGRESS_POD=$(kubectl get pod -l istio=ingressgateway -n istio-system -o jsonpath="{.items[0].metadata.name}")
INGRESS_POD_UID=$(kubectl get pods -n istio-system $INGRESS_POD -o jsonpath='{.metadata.uid}')
SPIRE_SERVER_POD=$(kubectl get pod -l app=spire-server -n spire -o jsonpath="{.items[0].metadata.name}")

# Register the spire agent
kubectl exec -n spire $SPIRE_SERVER_POD -- \
/opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s_psat:cluster:demo-cluster \
    -selector k8s_psat:agent_ns:spire \
    -selector k8s_psat:agent_sa:spire-agent \
    -node -socketPath /run/spire/sockets/server.sock

# Register the ingress gateway
kubectl exec -n spire $SPIRE_SERVER_POD -- \
/opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/istio-system/sa/istio-ingressgateway-service-account \
    -parentID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s:sa:istio-ingressgateway-service-account \
    -selector k8s:ns:istio-system \
    -selector k8s:pod-uid:$INGRESS_POD_UID \
    -dns $INGRESS_POD \
    -dns istio-ingressgateway.istio-system.svc \
    -socketPath /run/spire/sockets/server.sock


# Deploy a sleep app
echo "Deploy sleep app... ENTER to continue"
read -s
istioctl kube-inject --filename resources/sleep-spire.yaml | kubectl apply -f -

echo "Waiting for default namespace..."
./scripts/check.sh istio-1 default

SLEEP_POD=$(kubectl get pod -l app=sleep -o jsonpath="{.items[0].metadata.name}")
SLEEP_POD_UID=$(kubectl get pods $SLEEP_POD -o jsonpath='{.metadata.uid}')


echo "Register sleep app.. ENTER to continue"
read -s
# Register the sleep app
kubectl exec -n spire spire-server-0 -- \
/opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ns/default/sa/sleep \
    -parentID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s:ns:default \
    -selector k8s:pod-uid:$SLEEP_POD_UID \
    -dns $SLEEP_POD \
    -socketPath /run/spire/sockets/server.sock

# verify workload registrations
echo "Verify workoads... ENTER to continue"
read -s
kubectl exec -i -t $SPIRE_SERVER_POD -n spire -c spire-server -- /bin/sh -c "bin/spire-server entry show -socketPath /run/spire/sockets/server.sock"

# Inspect certificate for sleep pod

istioctl proxy-config secret $SLEEP_POD -o json | jq -r \
'.dynamicActiveSecrets[0].secret.tlsCertificate.certificateChain.inlineBytes' | base64 --decode | step certificate inspect -

