# This call has the correct token and the correct origin so we should see
# the following headers in the response:
# - access-control-allow-origin: http://istio.io
# - access-control-allow-credentials: true
source ./token-export.sh

curl -i -H "Host: istioinaction.io" -H "Origin: http://istio.io" -H "foo: bar" http://$(istioctl-ip)  -H "Authorization: Bearer $TOKEN"