# cloud-dev
GCE image for development via RDP

## How to use
 1. Create an instance from instance template 'cloud-dev'
 :warning: NOTE: DO NOT FORGET SETTING THE NEAREST REGION FROM YOUR LOCATION
 2. Connect the instance via SSH
 3. Save ~/.ssh/id_rsa
 4. Create a directory ~/.kube
 5. Save ~/.kube/service_account_gcp.json
 6. Launch this script
```
cd ~/
git clone http://github.com/alunir/cloud-dev
chmod +x ./cloud-dev/cloud-dev.sh
./cloud-dev/cloud-dev.sh
```
