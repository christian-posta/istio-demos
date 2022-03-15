source env.sh

VM_IP=$(gcloud compute instances describe --zone "$VM_ZONE" "$VM_NAME" --project "solo-public" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo $VM_IP