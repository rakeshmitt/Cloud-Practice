
module "vminstance" {
	source = "./vminstance"
	CLIENT_SECRET=local.CLIENT_SECRET
	CLIENT_ID=local.CLIENT_ID
	PROVISION_SCALESETS=local.PROVISION_SCALESETS
	PROVIDER=local.PROVIDER
	SUBSCRIPTION_ID=local.SUBSCRIPTION_ID
	TENANT_ID=local.TENANT_ID
	RESOURCE_GROUP_NAME=local.RESOURCE_GROUP_NAME
	AZ_ACR_NAME = "xxxxxxxxx"
	APP_HOST_PORT = "8080"
	CONTAINER_PORT = "8080"
	CONTAINER_IMAGE = "xxxxxxx.azurecr.io/fleetman"
	INSTANCE_NAME = "fleetman1"
	ADMIN_USERNAME = "xxxxxx"
	ADMIN_PWD = "xxxxxx"
	VNET_SUBNET_NAME = "VNET_AKS_SN"
	VNET_NAME = "VNET_AKS"
	VM_IMAGE_PUBLISHER = "Canonical"
	VM_IMAGE_OFFER = "UbuntuServer"
	VM_IMAGE_SKU = "16.04-LTS"
	VM_IMAGE_VERSION = "latest"
	STORAGE_ACC_TYPE = "Standard_LRS"
	LOCATION = "eastus"
	VM_SIZE = "Standard_D2_v2"
	AZ_SSH_KEY = "AZVM_KeyPair"
	USER_DATA_SCRIPT_FILE = "./vminstance/dockeragent.sh"
}

output "azurevm_public_ip" {
	value=local.AZUREVM_PUBLIC_IP
}

module "vmscaleset" {
	source = "./vmscaleset"
	CLIENT_SECRET=local.CLIENT_SECRET
	CLIENT_ID=local.CLIENT_ID
	PROVISION_SCALESETS=local.PROVISION_SCALESETS
	PROVIDER=local.PROVIDER
	SUBSCRIPTION_ID=local.SUBSCRIPTION_ID
	TENANT_ID=local.TENANT_ID
	RESOURCE_GROUP_NAME=local.RESOURCE_GROUP_NAME
	NBR_OF_INSTANCES = "2"
	VMSET_SKU = "Standard_D2_v2"
	AVAILABILITY_ZONE = ["1","2"]
	SCALE_IN_POLICY = "Default"
	AZ_ACR_NAME = "xxxxxxxxxxreg"
	APP_HOST_PORT = "8080"
	CONTAINER_PORT = "8080"
	CONTAINER_IMAGE = "xxxxxxxxxxreg.azurecr.io/xxxxx"
	INSTANCE_NAME = "xxxxx"
	ADMIN_USERNAME = "xxxxxxxxx"
	ADMIN_PWD = "xxxxxxxxxxx"
	VNET_SUBNET_NAME = "xxxxxxxxxx"
	VNET_NAME = "VNET_AKS"
	VM_IMAGE_PUBLISHER = "Canonical"
	VM_IMAGE_OFFER = "UbuntuServer"
	VM_IMAGE_SKU = "16.04-LTS"
	VM_IMAGE_VERSION = "latest"
	STORAGE_ACC_TYPE = "Standard_LRS"
	LOCATION = "eastus"
	LB_SKU = "Standard"
	LB_RULE_PROTOCOL = "Tcp"
	LB_FRONTEND_PORT = "8080"
	LB_BACKEND_PORT = "8080"
	DESIRED_INSTANCE = "1"
	MIN_INSTANCE = "1"
	MAX_INSTANCE = "3"
	SCALE_OUT_CPU_PCT_THRESHOLD = "75"
	SCALE_OUT_ACTION_INSTANCE_INCR_COUNT = "1"
	SCALE_IN_CPU_PCT_THRESHOLD = "25"
	SCALE_IN_ACTION_INSTANCE_DECR_COUNT = "1"
	SOURCE_PORT_RANGE = "*"
	DEST_PORT_RANGE = "*"
	USER_DATA_SCRIPT_FILE = "./vmscaleset/dockeragent.sh"
}

output "azurevmset_lb_ip" {
	value=local.AZUREVMSET_LB_IP
}

locals {
	CLIENT_SECRET="xxxxxxxxxxxxxxxxx"
	AZUREVMSET_LB_IP=module.vmscaleset.azurevmset_lb_ip
	CLIENT_ID="xxxxxxxxxxxxxxxxxxx"
	PROVISION_SCALESETS="false"
	PROVIDER="azurerm"
	SUBSCRIPTION_ID="xxxxxxxxxxxxxxxxxxxxxxxx"
	TENANT_ID="xxxxxxxxxxxxxxxxxxxxxx"
	RESOURCE_GROUP_NAME="xxxxxxxxxx"
	AZUREVM_PUBLIC_IP=module.vminstance.azurevm_public_ip
}
