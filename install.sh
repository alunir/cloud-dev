#!/bin/sh
echo "Setup cloud-dev"

echo "1. git"
read -p "Did you save id_rsa to ~/.ssh/id_rsa?"
ls -l ~/.ssh/id_rsa
ssh -T git@github.com & echo 'Success!'

read -p "Cloning alunir repository in ~/Document?"
cd ~/Document
# https://qiita.com/rorensu2236/items/df7d4c2cf621eeddd468
git clone ssh://git@github.com/alunir/alunir
cd ./alunir; git remote set-url origin git@github.com:alunir/alunir.git

echo "2. gcloud"
read -p "Did you save service_account_gcp.json to ~/.kube?"
ls -l ~/.kube

read -p "Starting gcloud auth login"
gcloud auth login
pause
gcloud auth activate-service-account 654650874191-compute@developer.gserviceaccount.com --key-file=/root/.kube/service_account_gcp.json
pause
gcloud auth configure-docker
pause
read -p "gcloud container clusters get-credentials"
gcloud container clusters get-credentials alunir --region us-central1-a

echo "Finished!"
