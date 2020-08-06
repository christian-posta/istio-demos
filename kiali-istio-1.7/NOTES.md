Boot Minikube for this!
from the kiali/hack folder

./boot-minikube.sh start --dex-enabled true -kv 1.18.0 --kubernetes-driver hyperkit



First you need to enable the Prometheus Addon!

kubectl apply -f samples/addons/prometheus.yaml -n istio-system


Get it going with default kiali OOTB, anonymous

kubectl apply -f samples/addons/kiali.yaml

kubectl create secret generic kiali -n istio-system --from-literal "username=admin" --from-literal "passphrase=admin”

sample CR for Kiali
https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml


login and ldap are DEPRECATED

For the login, anonymous, and ldap login options, the content displayed in Kiali is based on the permissions of the Kiali service account. On Kubernetes, the Kiali service account has cluster wide access and will be able to display everything in the cluster. 


For Token auth:

kubectl create serviceaccount kiali-dashboard -n istio-system

create binding:


kubectl create clusterrolebinding kiali-dashboard-admin --clusterrole=cluster-admin --serviceaccount=istio-system:kiali-dashboard

get token:

k get secret -n istio-system -o jsonpath="{.data.token}" $(k get secret -n istio-system | grep kiali-dashboard | awk '{print $1}' ) | base64 --decode


NOTE WE SHOULD CLEAN UP THESE ACCOUNTS AND ROLES

kubectl delete sa kiali-dashboard -n istio-system
kubectl delete clusterrolebinding kiali-dashboard-admin




  Username: admin@example.com
  Password: password

  http://192.168.64.115/kiali