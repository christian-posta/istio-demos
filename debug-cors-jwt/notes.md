# Set up the Istio scenario

~/istio-demos/istio-mtls-demo/setup.sh

## apply the cors config 
kubectl apply -f ./istio/cors/

## apply security at either the edge or the app
kubectl apply -f ./istio/security/gateway/request-auth.yaml


# Preflight:
curl -X OPTIONS -v -H "Host: istioinaction.io" -H "Origin: http://istioinaction.io" -H "Access-Control-Request-Method: GET" $(istioctl-ip) 


# Working with jwt token
curl -v -H "Host: istioinaction.io" -H "Origin: http://istioinaction.io" -H "Access-Control-Request-Method: GET" $(istioctl-ip)  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaXNzIjoic29sby5pbyIsImF1ZCI6WyJnbG9vIl0sImFkbWluIjp0cnVlLCJpYXQiOjE1MTYyMzkwMjJ9.CGR26-x_1XBzATv__R_obgXYLZ5C3BQvSBsCYd-HEIh__ffB1Lz3h6lQrGod8Ft-2N0vBnmoXb0k4v6Rq3hY6rVltPyOVDGIdVDykDb-mToNw2MHcNRbuTTjo3IsTNvX1hw0DeQztjFd6siozVwoP6Hqiax-MZVxn-hsr2mRsDOSwEgCk8GsJKxwevwwg75JI3JPZ09AHdSpumqS1o6_PCMkDyl00WwUUheCXtK8YCVFhHJsO-p-1T_5PiNsZdFWC9LUJcsSamsH0WwvuHU52gx-eIjKME9MYACR28YSVHMMKdMdMkrSNsuOJ9BXw92LQdK0-p14varmUgcB99x4bA"

kubectl create cm envoy --from-file=envoy.yaml=./envoy-conf.yaml -o yaml --dry-run=client | k apply -f -
kubectl rollout restart deploy/envoy

PREFLIGHT:
k port-forward svc/envoy 8080:80

curl -v -X OPTIONS -H "Host: istioinaction.io" -H "Origin: http://istio.io" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: foo"   localhost:8080/

ACTUAL CALL
curl -v  -H "Host: istioinaction.io" -H "Origin: http://istio.io" -H "Access-Control-Request-Method: GET" -H "foo: bar" localhost:8080/headers


CHECK STATS

k port-forward svc/envoy 8081:15000
curl localhost:8081/stats | grep cors