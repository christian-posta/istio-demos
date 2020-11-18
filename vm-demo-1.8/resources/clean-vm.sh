export ROOT_FOLDER=work
export FILES=./demo-cluster-name/vm-services

./stop-istio.sh

rm -fr /var/run/secrets/istio
rm -fr /var/run/secrets/tokens


# Install sidecar
echo "Installing sidecar"
sudo dpkg -P istio-sidecar
rm -fr /var/lib/istio

sudo sed -i '/istio/d' /etc/hosts
sudo sed -i '/vm-services/d' /etc/hosts

sudo rm -fr /etc/istio/proxy
sudo rm -fr /var/log/istio

sudo systemctl reset-failed
sudo systemctl daemon-reload