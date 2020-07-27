#!/bin/sh
echo "Interactive install commands for cloud-dev"

if [ ! -e ~/.ssh/id_rsa ]; then
  echo "Not found ~/.ssh/id_rsa"
  exit 1
fi
chmod 600 ~/.ssh/id_rsa

if [ ! -e ~/.kube/service_account_gcp.json ]; then
  echo "Not found ~/.kube/service_account_gcp.json"
  exit 1
fi

echo "Set GIT_USER_NAME (e.g. jimako)"
read GIT_USER_NAME

echo "Set GIT_USER_EMAIL (e.g. nsplat@gmail.com)"
read GIT_USER_EMAIL

echo "Set GOOGLE_ACCOUNT_ID (e.g. nsplat@gmail.com)"
read GOOGLE_ACCOUNT_ID

echo "Set VM_REGION (e.g. asia-northeast1)"
read VM_REGION

# User Setting
sudo adduser $USER
sudo gpasswd -a $USER sudo
sudo passwd $USER

# mount
# see. https://cloud.google.com/compute/docs/disks/add-persistent-disk?hl=ja#formatting
# sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
# sudo mkdir -p /mnt/disks
# sudo mount -o discard,defaults /dev/sdb /mnt/disks
# sudo chmod a+w /mnt/disks
# sudo cp /etc/fstab /etc/fstab.bkp
# UUID=`sudo blkid /dev/sdb | awk '{print $2}' | sed -e s/UUID=//g | sed -e 's/\"//g'`
# echo "UUID: "$UUID
# echo UUID="${UUID}" /mnt/disks ext4 discard,defaults,nobootwait 0 2 | sudo tee -a /etc/fstab
# sudo mkdir -p /mnt/disks/snap
# sudo ln -s /mnt/disks/snap /

# Skip interactive installation for git
export DEBIAN_FRONTEND=noninteractive

sudo apt update && sudo apt install -y gnome-core xrdp

sudo apt-get install -y docker.io
docker --version

## git configuration
# http://crossbridge-lab.hatenablog.com/entry/2016/11/11/073000
sudo apt-get install -y openssh-client
mkdir -p ~/.ssh
sudo echo 'Host github.com\n  HostName github.com\n  IdentityFile ~/.ssh/id_rsa\n  User git' > ~/.ssh/config

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpNIFcvoSEHnizei7sYsoRK1tBYfHtkGkWiwkTXtoWiAyDkIYU6RzGiMxh7wInwKWMVY9OieD4cJYAQvUQpCKRZNIrDyOui5E4yCfuSiWzcUP0C9i6MqlKK18SB0Sxw6sUrwtRa9kbrpV+bM3B6ti/mMe92atJ7X13tuRny+qWXHUoooDW5yBq/abKgBsbIPLQ2WeH26VmvjnEDQvccanvn76ZpvT99XY6tECwpOfREejptkUzKCcYarHe4ezWK/rlMO91WgM+6rror5ym59rC1tDVxb0zttjPDecugO6benCiHcPTYxiOsAGb6tiIkva0QdtbCvtz6z40tiNJjE83 jimako@jimako-MacBook.local" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

git config --global user.email $GIT_USER_EMAIL
git config --global user.name $GIT_USER_NAME

# gcloud configuration
# https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=ja
sudo apt-get install -y curl
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install -y google-cloud-sdk

gcloud config configurations create cloud-dev
gcloud config set account GOOGLE_ACCOUNT_ID

read -p "Starting gcloud auth login"
gcloud auth login

# see https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?hl=ja#promote_ephemeral_ip
IP_ADDRESS=`curl ifconfig.io`
echo $IP_ADDRESS

gcloud compute addresses create static-ip --addresses $IP_ADDRESS --region $VM_REGION

ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
# git
ssh -T git@github.com || echo 'SSH Connection Success!'


mkdir -p ~/alunir
cd ~/alunir
# https://qiita.com/rorensu2236/items/df7d4c2cf621eeddd468
git clone ssh://git@github.com/alunir/alunir
cd ./alunir; git remote set-url origin git@github.com:alunir/alunir.git


# ???
# gcloud auth activate-service-account 654650874191-compute@developer.gserviceaccount.com --key-file=~/.kube/service_account_gcp.json
gcloud auth configure-docker

# install go with snap
mkdir -p /go
sudo snap install --classic go
go env -w GOPATH=/go
go env -w GOPROXY=direct
go env -w GOPRIVATE=github.com/alunir

sudo snap install --classic code
sudo snap install --classic kubectl
sudo snap install --classic kompose

read -p "gcloud container clusters get-credentials"
gcloud container clusters get-credentials alunir --region us-central1-a

echo export PATH=$PATH:`go env GOPATH`/bin/ >> ~/.profile
echo export GOPATH=`go env GOPATH` >> ~/.profile

cp ./settings.json ~/$USER_NAME/.config/Code/User/

echo "Finished! Recommend to save here to a VM Image"
