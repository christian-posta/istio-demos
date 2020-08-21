ROOT_FOLDER=work
FILES=./demo-cluster-name/vm-services

# prep apt
echo "Prepping apt"
sudo apt -y update
sudo apt -y upgrade

# cp secrets
echo "Installing secrets"
sudo mkdir -p /var/run/secrets/istio
sudo cp "${FILES}"/root-cert.pem /var/run/secrets/istio/root-cert.pem

sudo  mkdir -p /var/run/secrets/tokens
sudo cp "${FILES}"/istio-token /var/run/secrets/tokens/istio-token

# Install sidecar
echo "Installing sidecar"
curl -LO https://storage.googleapis.com/istio-release/releases/1.7.0-rc.3/deb/istio-sidecar.deb
sudo dpkg -i istio-sidecar.deb

# Install cluster.env
echo "Installing cluster.env"
sudo cp "${FILES}"/cluster.env /var/lib/istio/envoy/cluster.env

# Install sidecar.env
echo "Installing sidecar.env"
sudo cp "${FILES}"/sidecar.env /var/lib/istio/envoy/sidecar.env

# Update /etc/hosts
echo "Update /etc/hosts"
sudo sh -c "cat $(eval echo ~$SUDO_USER)/$ROOT_FOLDER/$FILES/hosts-addendum >> /etc/hosts"

# Add root cert 
echo "Adding root cert"
sudo cp "${FILES}"/root-cert.pem /var/run/secrets/istio/root-cert.pem

# transfer ownership of files
sudo mkdir -p /etc/istio/proxy
sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy  /var/run/secrets


FILE=/etc/dnsmasq.conf
if test -f "$FILE"; then
    sudo bash -c "echo $(cat ${FILES}/dnsmasq-snippet.conf) >> /etc/dnsmasq.conf"
    
    sudo sed -i 's/^#DNS=/DNS=127.0.0.1/' /etc/systemd/resolved.conf
    sudo sed -i 's/^#Domains=/Domains=~svc.cluster.local/' /etc/systemd/resolved.conf
fi