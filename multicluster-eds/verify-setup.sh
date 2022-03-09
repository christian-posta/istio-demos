# Assume that we have Istio installed on all the three clusters


echo "Calling from cluster 1"
for i in {1..10}
do
    kubectl exec --context istio-1 -n sample -c sleep deploy/sleep -- curl -sS helloworld.sample:5000/hello
done





echo "Calling from cluster 2"
for i in {1..10}
do
    kubectl exec --context istio-2 -n sample -c sleep deploy/sleep -- curl -sS helloworld.sample:5000/hello
done




echo "Calling from cluster 3"
for i in {1..10}
do
    kubectl exec --context istio-3 -n sample -c sleep deploy/sleep -- curl -sS helloworld.sample:5000/hello
done