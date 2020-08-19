
# Install dnsmasq
sudo apt-get install dnsmasq

# See config for dnsmasq
cat /etc/dnsmasq.conf 

# add the address in question, eg:
address=/.svc.cluster.local/10.44.0.0  

# restart dnsmasq
systemctl list-units --type=service
sudo systemctl restart dnsmasq.service

# check you can query it through dnsmasq
nslookup httpbin.default.svc.cluster.local 127.0.0.1

# prob won't be able to through default resolver though
cat /etc/resolv.conf 
nslookup httpbin.default.svc.cluster.local 127.0.0.53

# so update the resolved conf:
[Resolve]
DNS=127.0.0.1
Domains=~svc.cluster.local

# restart resolved
sudo systemctl restart systemd-resolved.service

# should work now
nslookup httpbin.default.svc.cluster.local 127.0.0.53

# curl a service in k8s
curl -v httpbin.default.svc.cluster.local:8000/headers
