module "vmscaleset_appgw" {
	source = "./vmscaleset_appgw"
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
	AZ_ACR_NAME = "cxxxxxx"
	APP_HOST_PORT = "8080"
	CONTAINER_PORT = "8080"
	CONTAINER_IMAGE = "xxxxxx.azurecr.io/xxxxxxx"
	INSTANCE_NAME = "xxxxxxxxxxx"
	ADMIN_USERNAME = "xxxxxxxxxx"
	ADMIN_PWD = "xxxxxxxxxxxxx"
	VNET_SUBNET_NAME = "default"
	VNET_NAME = "xxxxxxxxxxx-vnet"
	VM_IMAGE_PUBLISHER = "Canonical"
	VM_IMAGE_OFFER = "UbuntuServer"
	VM_IMAGE_SKU = "16.04-LTS"
	VM_IMAGE_VERSION = "latest"
	STORAGE_ACC_TYPE = "Standard_LRS"
	LOCATION = "westus"
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
	USER_DATA_SCRIPT_FILE = "./vmscaleset_appgw/dockeragent.sh"
}

output "azurevmset_lb_ip" {
	value=local.AZUREVMSET_LB_IP
}

locals {
	CLIENT_ID="xxxxxxxxxxxxxxxxxxxxxxx"
	CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxxxx"
	AZUREVMSET_LB_IP=module.vmscaleset_appgw.azurevmset_lb_ip
	PROVISION_SCALESETS="true"
	PROVIDER="azurerm"
	SUBSCRIPTION_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
	TENANT_ID="xxxxxxxxxxxxxxxxxxxxxxxx"
	RESOURCE_GROUP_NAME="xxxxxxxxxxxxxxxxx"
	#AZUREVM_PUBLIC_IP=module.vminstance.azurevm_public_ip
}
