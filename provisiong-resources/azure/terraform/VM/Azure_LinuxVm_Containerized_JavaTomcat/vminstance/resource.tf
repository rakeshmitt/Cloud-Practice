variable PROVIDER	{}
variable SUBSCRIPTION_ID	{}
variable CLIENT_ID	{}
variable CLIENT_SECRET	{}
variable TENANT_ID	{}
variable PROVISION_SCALESETS {}
variable AZ_ACR_NAME	{}
variable APP_HOST_PORT	{}
variable CONTAINER_PORT	{}
variable CONTAINER_IMAGE	{}
variable INSTANCE_NAME	{}
variable RESOURCE_GROUP_NAME	{}
variable LOCATION	{}
variable VM_SIZE 	{}
variable ADMIN_USERNAME {}
variable ADMIN_PWD	{}
variable VM_IMAGE_PUBLISHER {}
variable VM_IMAGE_OFFER	{}
variable VM_IMAGE_SKU	{}
variable VM_IMAGE_VERSION	{}
variable STORAGE_ACC_TYPE	{}
variable USER_DATA_SCRIPT_FILE	{}
variable VNET_SUBNET_NAME	{}
variable VNET_NAME	{}
variable AZ_SSH_KEY	{}


provider "azurerm" {  
  subscription_id = var.SUBSCRIPTION_ID
  client_id       = var.CLIENT_ID
  client_secret   = var.CLIENT_SECRET
  tenant_id       = var.TENANT_ID
  features {}
}

/*
data "azurerm_ssh_public_key" "sshkey" {
  name                = var.AZ_SSH_KEY
  resource_group_name = var.RESOURCE_GROUP_NAME
}
*/

data "template_file" "user_data" {
  template = base64encode(templatefile(var.USER_DATA_SCRIPT_FILE, 
		{ client_id = var.CLIENT_ID,
		  client_secret = var.CLIENT_SECRET,
		  tenant_id	= var.TENANT_ID,
		  az_acr_name = var.AZ_ACR_NAME,
		  app_host_port = var.APP_HOST_PORT,
		  container_port = var.CONTAINER_PORT,
		  container_image = var.CONTAINER_IMAGE
		}))
 }
 
 
data "azurerm_subnet" "subnet" {
  name                 = var.VNET_SUBNET_NAME
  virtual_network_name = var.VNET_NAME
  resource_group_name  = var.RESOURCE_GROUP_NAME
}

resource "azurerm_public_ip" "public" {
  count = var.PROVISION_SCALESETS ? 0 : 1
  name                = format("%s-PIP", var.INSTANCE_NAME)
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.LOCATION
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "primary" {
  count = var.PROVISION_SCALESETS ? 0 : 1
  name                = format("%s-NIC", var.INSTANCE_NAME)
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.LOCATION

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public[0].id
  }
}
 

resource "azurerm_linux_virtual_machine" "linux_instance" {
  count = var.PROVISION_SCALESETS ? 0 : 1
  name                            = format("%s-VM", var.INSTANCE_NAME)
  resource_group_name             = var.RESOURCE_GROUP_NAME
  location                        = var.LOCATION
  size                            = var.VM_SIZE
  disable_password_authentication = false
  admin_username                  = var.ADMIN_USERNAME
  admin_password                  = var.ADMIN_PWD
  
 # admin_ssh_key {
  #      username       = var.ADMIN_USERNAME
   #     public_key     = data.azurerm_ssh_public_key.sshkey.public_key
   # }
  
  network_interface_ids = [azurerm_network_interface.primary[0].id]
  custom_data = data.template_file.user_data.rendered
  
  source_image_reference {
    publisher = var.VM_IMAGE_PUBLISHER
    offer     = var.VM_IMAGE_OFFER
    sku       = var.VM_IMAGE_SKU
    version   = var.VM_IMAGE_VERSION
  }

  os_disk {
    storage_account_type = var.STORAGE_ACC_TYPE
    caching              = "ReadWrite"
  }
}

output "azurevm_public_ip"{
  value = var.PROVISION_SCALESETS ? "" : azurerm_linux_virtual_machine.linux_instance[0].public_ip_address  
}
