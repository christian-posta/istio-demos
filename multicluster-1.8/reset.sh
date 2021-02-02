. ./env.sh

kubectl --context $CLUSTER_1 -n foo delete -f temp/httpbin-se.yaml

rm temp/*.*