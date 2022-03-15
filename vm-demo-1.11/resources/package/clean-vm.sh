export ROOT_FOLDER=work
export FILES=./files

# Flush iptables
echo "Flushing iptables"
sudo iptables -F -t nat

echo "Stopping istio"
./stop-istio.sh

rm /etc/certs/*.*
rm -fr /var/run/secrets/istio
rm -fr /var/run/secrets/tokens


# Install sidecar
echo "Remove sidecar"
sudo dpkg -P istio-sidecar
rm -fr /var/lib/istio

sudo sed -i '/istio/d' /etc/hosts
sudo sed -i '/vm-services/d' /etc/hosts

sudo rm -fr /etc/istio/proxy
sudo rm -fr /var/log/istio

sudo systemctl reset-failed
sudo systemctl daemon-reload

