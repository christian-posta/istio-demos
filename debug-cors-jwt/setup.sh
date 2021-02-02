pushd ../istio-mtls-demo
./setup.sh
popd

kubectl apply -f istio/cors/

echo "CORS is set up, can now start adding auth"