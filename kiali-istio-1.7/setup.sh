echo "Make sure you booted the minikube and installed Istio 1.7!!!"
read -s

rm -fr temp
# Install Prom
 
 kubectl -n istio-system apply -f /Users/ceposta/dev/istio/istio-1.7.0-beta.1/samples/addons/prometheus.yaml

# Install Kiali
# May need to run this back to back because of the CRD race
kubectl create ns kiali-operator
kubectl apply -f /Users/ceposta/dev/istio/istio-1.7.0-beta.1/samples/addons/kiali.yaml

DASHED_IP=$(minikube ip | sed 's/\./-/g')
mkdir temp
#DASHED_IP=$(minikube ip)
sed s/MINIKUBE_IP/$DASHED_IP/g resources/kiali-auth-oidc-template.yaml > temp/kiali-auth-oidc.yaml