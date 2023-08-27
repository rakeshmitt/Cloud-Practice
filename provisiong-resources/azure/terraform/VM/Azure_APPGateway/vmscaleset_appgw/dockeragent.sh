#!/bin/bash
# Install docker
apt-get update
apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
echo "<<<<<<<<<<<<<<<<<<<<apt-get update done>>>>>>>>>>>>>>>>>>>"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo "<<<<<<<<<<<<<<<<<<<<azure cli update>>>>>>>>>>>>>>>>>>>"
apt-get install -y docker-ce
usermod -aG docker ubuntu
systemctl status docker
echo "<<<<<<<<<<<<<<<<<<<<docker status>>>>>>>>>>>>>>>>>>>"


# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


az login --service-principal -u ${client_id} -p ${client_secret} --tenant ${tenant_id}
echo "<<<<<<<<<<<<<<<<<<<<AZ Login>>>>>>>>>>>>>>>>>>>"
az acr login --name ${az_acr_name}
echo "<<<<<<<<<<<<<<<<<<<<AZ ACR Login>>>>>>>>>>>>>>>>>>>"
docker container run -p ${app_host_port}:${container_port} -d ${container_image}