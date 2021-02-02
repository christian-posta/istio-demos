# In this call, we don't properly match the origin in the CORS filter
# but the request is fine and CORS filter is enabled, so we should see
# a response of 
# - "access-control-allow-origin: *"

source ./token-export.sh

curl -i -H "Host: istioinaction.io" -H "Origin: http://istioinaction.io" -H "Access-Control-Request-Method: POST,PUT" -H "Access-Control-Request-Headers: foo" http://$(istioctl-ip)  -H "Authorization: Bearer $TOKEN"