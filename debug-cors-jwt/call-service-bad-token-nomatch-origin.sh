# In this call we have a bad token, so it should fail JWT
# but we should probably expect to see the CORS headers, something similar to:
# - "access-control-allow-origin: *"

##### BUT FOR SOME REASON WE DON'T


curl -i -H "Host: istioinaction.io" -H "Origin: http://istioinaction.io" -H "foo: bar" $(istioctl-ip)  -H "Authorization: Bearer 12345"