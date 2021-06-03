kubectl cp ./prep-vault-ca.sh vault/vault-0:/vault
kubectl exec -it -n vault po/vault-0 -- sh -c "/vault/prep-vault-ca.sh"