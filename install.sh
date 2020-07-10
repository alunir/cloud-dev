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

# mount
echo "3. mount"
read -p "Did you mount /dev/sdb?"
UUID=(blkid /dev/sdb | awk '{print $2}' | sed -e s/UUID=//g | sed -e 's/\"//g')
mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
mkdir -p /mnt/disks
mount -o discard,defaults /dev/sdb /mnt/disks
chmod a+w /mnt/disks
cp /etc/fstab /etc/fstab.bkp
eval UUID="\$UUID" /mnt/disks ext4 discard,defaults,nobootwait 0 2 >> /etc/fstab
ln -s /mnt/disks/snap

# snap
echo "4. snap"
read -p "snap install go?"
snap install go; \
go env -w GOPATH=/mnt/disks/go; \
go env -w GOPROXY=direct; \
go env -w GOPRIVATE=github.com/alunir

read -o "snap install VSCode, kubectl, kompose?"
snap install --classic code kubectl kompose

read -p "gcloud container clusters get-credentials"
gcloud container clusters get-credentials alunir --region us-central1-a

echo "Finished!"

