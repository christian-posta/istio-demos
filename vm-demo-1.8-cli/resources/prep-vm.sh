ROOT_FOLDER=work
PROV_CERTS=/etc/certs
FILES=./files

# prep apt
echo "Prepping apt"
sudo apt -y update
sudo apt -y upgrade

# cp secrets
echo "Installing secrets"

sudo mkdir -p $PROV_CERTS
sudo cp "${FILES}"/root-cert.pem "$PROV_CERTS/root-cert.pem"

sudo  mkdir -p /var/run/secrets/tokens
sudo cp "${FILES}"/istio-token /var/run/secrets/tokens/istio-token

# Install sidecar
echo "Installing sidecar"
curl -LO https://storage.googleapis.com/istio-release/releases/1.8.0/deb/istio-sidecar.deb
sudo dpkg -i istio-sidecar.deb

# Install cluster.env
echo "Installing cluster.env"
sudo cp "${FILES}"/cluster.env /var/lib/istio/envoy/cluster.env

echo "Installing sidecar.env"
sudo cp "${FILES}"/sidecar.env /var/lib/istio/envoy/sidecar.env

# Install cluster.env
echo "Mesh  Config"
sudo cp "${FILES}"/mesh.yaml /etc/istio/config/mesh

# Update /etc/hosts
echo "Update /etc/hosts"
sudo sh -c "cat $(eval echo ~$SUDO_USER)/$ROOT_FOLDER/$FILES/hosts >> /etc/hosts"

# transfer ownership of files
sudo mkdir -p /etc/istio/proxy
sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets /etc/certs/root-cert.pem
