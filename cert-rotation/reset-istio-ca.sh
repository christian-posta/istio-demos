kubectl delete secret cacerts -n istio-system
kubectl delete secret istio-ca-secret -n istio-system
kubectl delete cm -n istio-system istio-security
kubectl delete po --wait=false -n istio-system -l app=istiod 
rm -f ./certs/current-istio/*.*

echo "Let's wait until istiod comes up and writes all the config maps"
sleep 30s
kubectl delete po -n default --all
