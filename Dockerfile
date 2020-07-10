FROM ubuntu:latest
MAINTAINER jimako1989

RUN apt update && apt install -y sudo xrdp

RUN apt-get install -y docker.io
RUN docker --version

## git configuration
# http://crossbridge-lab.hatenablog.com/entry/2016/11/11/073000
RUN apt-get install -y openssh-client
RUN mkdir -p /root/.ssh
RUN echo 'Host github.com\n  HostName github.com\n  IdentityFile ~/.ssh/id_rsa\n  User git' > /root/.ssh/config

RUN git config --global user.email "nsplat@gmail.com"; \
    git config --global user.name "jimako"

RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

# gcloud configuration
# https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=ja
RUN apt-get install -y curl
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

RUN gcloud config configurations create cloud-dev; \
    gcloud config set account nsplat@gmail.com

RUN mkdir -p /root/.kube

# mount
RUN UUID=(blkid /dev/sdb | awk '{print $2}' | sed -e s/UUID=//g | sed -e 's/\"//g') && \
    mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb && \
    mkdir -p /mnt/disks && \
    mount -o discard,defaults /dev/sdb /mnt/disks && \
    chmod a+w /mnt/disks && \
    cp /etc/fstab /etc/fstab.bkp && \
    eval UUID="\$UUID" /mnt/disks ext4 discard,defaults,nobootwait 0 2 >> /etc/fstab && \
    ln -s /mnt/disks/snap

# install go with snap
RUN mkdir -p /mnt/disks/go && \
    snap install go && \
    go env -w GOPATH=/mnt/disks/go && \
    go env -w GOPROXY=direct && \
    go env -w GOPRIVATE=github.com/alunir

RUN snap install --classic code kubectl kompose

COPY install.sh /root/

