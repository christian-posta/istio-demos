source env.sh


tar -czf work.tar.gz ./work
gcloud beta compute scp --scp-flag="-r" --zone "$VM_ZONE" work.tar.gz $VM_NAME:~ 

rm work.tar.gz