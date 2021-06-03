kubectl create ns vault
helm install vault hashicorp/vault --set "server.dev.enabled=true" -n vault

