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
curl -LO https://storage.googleapis.com/istio-build/dev/1.8-alpha.e4978a723dc2695e78ef1595e57819d3086330fa/deb/istio-sidecar.deb
#curl -LO https://storage.googleapis.com/istio-release/releases/1.8.0-alpha.2/deb/istio-sidecar.deb
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
