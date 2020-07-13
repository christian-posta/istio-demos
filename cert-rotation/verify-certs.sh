
BASE="./certs"
ROOTA_DIR="$BASE/ROOTA"
ROOTB_DIR="$BASE/ROOTB"
INTERMEDIATE_A="$BASE/intermediate-rootA"
INTERMEDIATE_A2="$BASE/intermediate-rootA2"
INTERMEDIATE_B="$BASE/intermediate-rootB"

echo "verifying root certs for CA-A"
diff $ROOTA_DIR/certs/root_ca.crt $INTERMEDIATE_A/root-cert.pem
step certificate verify $INTERMEDIATE_A/ca-cert.pem --roots $INTERMEDIATE_A/root-cert.pem 

echo "verifying root certs for CA-A2"
diff $ROOTA_DIR/certs/root_ca.crt $INTERMEDIATE_A2/root-cert.pem
step certificate verify $INTERMEDIATE_A2/ca-cert.pem --roots $INTERMEDIATE_A2/root-cert.pem 

echo "verifying root certs for CA-B"
diff $ROOTB_DIR/certs/root_ca.crt $INTERMEDIATE_B/root-cert.pem
step certificate verify $INTERMEDIATE_B/ca-cert.pem --roots $INTERMEDIATE_B/root-cert.pem 