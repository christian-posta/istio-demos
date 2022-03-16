## Some helpful commands:

gcloud beta compute scp --scp-flag="-r" --zone "us-west1-b" ./work ceposta-linux-builds:~ 

gcloud beta compute ssh --zone "us-west1-b" "ceposta-linux-builds" --project "solo-public"
gcloud beta compute ssh --zone "us-central1-a" "ceposta-disconnected-vm" --project "solo-public"

Enable firewall rules for services running on compute:
gcloud compute firewall-rules create test-http-8080 --allow tcp:9090 --source-tags=ceposta-linux-builds --source-ranges=0.0.0.0/0 --description="Allow testing http apps"


Listing iptables:
sudo iptables -t nat -L

Flush iptables rules:
sudo iptables -F -t nat

Sample server:
python3 -m http.server 9090
python -m SimpleHTTPServer 9090

Systemctl commands:
sudo systemctl start istio
systemctl list-units --type=service
sudo systemctl reset-failed
sudo systemctl daemon-reload

start istio
cat /usr/local/bin/istio-start.sh 

echo "to see logs, run"
echo "journalctl -u istio.service"

tail -f /var/log/istio/istio.log 


# calling the service on the vm from an in-mesh service:

curl vmservice.example.com

# using proxy-config from file
curl -s localhost:15000/config_dump | istioctl pc listeners --file -

echo {} | grpcurl -d @ -cacert ./files/root-cert.pem istiod.istio-system.svc:15012 envoy.service.discovery.v3.AggregatedDiscoveryService/StreamAggregatedResources

# Running the systemd unit file as root:

see resources/systemd-unit
cat /lib/systemd/system/istio.service 
Will need to `sudo systemctl daemon-reload` when making a change to the systemd-unit files...
