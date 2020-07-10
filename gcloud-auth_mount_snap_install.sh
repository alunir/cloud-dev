pause
gcloud auth login
pause
gcloud auth activate-service-account 654650874191-compute@developer.gserviceaccount.com --key-file=/root/.kube/service_account_gcp.json
pause
gcloud auth configure-docker
pause

# mount
UUID=(blkid /dev/sdb | awk '{print $2}' | sed -e s/UUID=//g | sed -e 's/\"//g'); \
mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb; \
mkdir -p /mnt/disks; \
mount -o discard,defaults /dev/sdb /mnt/disks; \
chmod a+w /mnt/disks; \
cp /etc/fstab /etc/fstab.bkp; \
eval UUID="\$UUID" /mnt/disks ext4 discard,defaults,nobootwait 0 2 >> /etc/fstab; \
ln -s /mnt/disks/snap

# snap
pause
snap install go; \
go env -w GOPATH=/mnt/disks/go; \
go env -w GOPROXY=direct; \
go env -w GOPRIVATE=github.com/alunir

snap install --classic code kubectl kompose

gcloud container clusters get-credentials alunir --region us-central1-a
