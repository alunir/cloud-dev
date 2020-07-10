#!/bin/sh
echo "Setup cloud-dev"

export DEBIAN_FRONTEND=noninteractive

apt update && apt install -y sudo xrdp

apt-get install -y docker.io
docker --version

## git configuration
# http://crossbridge-lab.hatenablog.com/entry/2016/11/11/073000
apt-get install -y openssh-client
mkdir -p /root/.ssh
echo 'Host github.com\n  HostName github.com\n  IdentityFile ~/.ssh/id_rsa\n  User git' > /root/.ssh/config

git config --global user.email "nsplat@gmail.com"
git config --global user.name "jimako"

ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

# gcloud configuration
# https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=ja
apt-get install -y curl
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

gcloud config configurations create cloud-dev
gcloud config set account nsplat@gmail.com

mkdir -p /root/.kube


# git
read -p "Did you save id_rsa to ~/.ssh/id_rsa?"
ls -l ~/.ssh/id_rsa
ssh -T git@github.com & echo 'Success!'

read -p "Cloning alunir repository in ~/Document?"
cd ~/Document
# https://qiita.com/rorensu2236/items/df7d4c2cf621eeddd468
git clone ssh://git@github.com/alunir/alunir
cd ./alunir; git remote set-url origin git@github.com:alunir/alunir.git

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
RUN UUID=`blkid /dev/sdb | awk '{print $2}' | sed -e s/UUID=//g | sed -e 's/\"//g'`
mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
mkdir -p /mnt/disks
mount -o discard,defaults /dev/sdb /mnt/disks
chmod a+w /mnt/disks
cp /etc/fstab /etc/fstab.bkp
eval UUID="\$UUID" /mnt/disks ext4 discard,defaults,nobootwait 0 2 >> /etc/fstab
ln -s /mnt/disks/snap

# install go with snap
mkdir -p /mnt/disks/go
snap install go
go env -w GOPATH=/mnt/disks/go
go env -w GOPROXY=direct
go env -w GOPRIVATE=github.com/alunir

RUN snap install --classic code kubectl kompose

read -p "gcloud container clusters get-credentials"
gcloud container clusters get-credentials alunir --region us-central1-a

echo "Finished!"
