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

FILE=/etc/dnsmasq.conf
if test -f "$FILE"; then
    #revert the dnsmasq changes
    sudo sed -i '/^address=\/.svc.cluster.local/d' /etc/dnsmasq.conf
    sudo systemctl restart dnsmasq.service

    # revert the resolved changes
    sudo sed -i 's/^DNS=127.0.0.1/#DNS=/' /etc/systemd/resolved.conf
    sudo sed -i 's/^Domains=~svc.cluster.local/#Domains=/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved.service
fi

sudo systemctl reset-failed
sudo systemctl daemon-reload