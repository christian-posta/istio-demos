gcloud beta compute scp --scp-flag="-r" --zone "us-west1-b" ./work ceposta-linux-builds:~ 

gcloud beta compute ssh --zone "us-west1-b" "ceposta-linux-builds" --project "solo-public"


sudo iptables -t nat -L