Some helpful commands:

gcloud beta compute scp --scp-flag="-r" --zone "us-west1-b" ./work ceposta-linux-builds:~ 

gcloud beta compute ssh --zone "us-west1-b" "ceposta-linux-builds" --project "solo-public"


sudo iptables -t nat -L

Enable firewall rules for services running on compute:

gcloud compute firewall-rules create test-http-8080 --allow tcp:9090 --source-tags=ceposta-linux-builds --source-ranges=0.0.0.0/0 --description="Allow testing http apps"


python -m SimpleHTTPServer 9090

sudo systemctl start istio

systemctl list-units --type=service

sudo systemctl reset-failed
sudo systemctl daemon-reload

start istio
cat /usr/local/bin/istio-start.sh 

echo "to see logs, run"
echo "journalctl -u istio.service"

tail -f /var/log/istio/istio.log 


echo {} | grpcurl -d @ -cacert ./demo-cluster-name/vm-services/root-cert.pem istiod.istio-system.svc:15012 envoy.service.discovery.v3.AggregatedDiscoveryService/StreamAggregatedResources
