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

COPY id_rsa /root/.ssh/

RUN git config --global user.email "nsplat@gmail.com"; \
    git config --global user.name "jimako"

RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

RUN ssh -T git@github.com & echo 'continue'

# https://qiita.com/rorensu2236/items/df7d4c2cf621eeddd468
RUN git clone ssh://git@github.com/alunir/alunir
RUN cd ./alunir; git remote set-url origin git@github.com:alunir/alunir.git

# gcloud configuration
# https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=ja
RUN apt-get install -y curl
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

RUN gcloud config configurations create cloud-dev; \
    gcloud config set account nsplat@gmail.com

RUN mkdir -p /root/.kube
COPY service_account_gcp.json /root/.kube

COPY gcloud-auth_mount_snap_install.sh /root/

