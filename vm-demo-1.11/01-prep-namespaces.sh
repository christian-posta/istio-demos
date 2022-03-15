
source env.sh

kubectl create namespace $VM_NAMESPACE
kubectl create serviceaccount $SERVICE_ACCOUNT -n $VM_NAMESPACE