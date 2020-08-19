source env.sh


tar -czf work.tar.gz ./work
gcloud beta compute scp --scp-flag="-r" --zone "us-west1-b" work.tar.gz ceposta-linux-builds:~ 

rm work.tar.gz