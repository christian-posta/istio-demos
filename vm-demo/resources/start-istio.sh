sudo systemctl start istio

# systemctl list-units --type=service
# start istio
# cat /usr/local/bin/istio-start.sh 

echo "to see logs, run"
echo "journalctl -u istio.service"

tail -f /var/log/istio/istio.log 