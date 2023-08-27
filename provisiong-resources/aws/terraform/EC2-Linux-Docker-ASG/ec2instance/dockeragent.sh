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
apt-get install -y awscli
apt-get install -y docker-ce
usermod -aG docker ubuntu
systemctl status docker


# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

aws configure set aws_access_key_id ${aws_access_key}
aws configure set aws_secret_access_key ${aws_secret_key}
aws configure set default.region ${aws_region}

if [ -n "${ecr_registry_url}" ]
then
	aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_registry_url}
fi

docker container run -p ${app_host_port}:${container_port} -d ${container_image}