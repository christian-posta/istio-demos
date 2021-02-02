# This is the preflight request and we exect all of the control/allow headers
# to be present in the response:
# - access-control-allow-origin: http://istio.io
# - access-control-allow-credentials: true
# - access-control-allow-methods: GET
# - access-control-allow-headers: foo,bar
# - access-control-max-age: 60

curl -i -X OPTIONS -H "Host: istioinaction.io" -H "Origin: http://istio.io" -H "Access-Control-Request-Method: GET" $(istioctl-ip) 