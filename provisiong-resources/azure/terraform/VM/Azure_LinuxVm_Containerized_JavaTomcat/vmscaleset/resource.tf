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
variable VMSET_SKU 	{}
variable AVAILABILITY_ZONE	{}
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
#variable AZ_SSH_KEY	{}
variable SCALE_IN_POLICY	{}
variable NBR_OF_INSTANCES	{}
variable LB_SKU	{}
variable LB_RULE_PROTOCOL  {}
variable LB_FRONTEND_PORT {}
variable LB_BACKEND_PORT  {}
variable DESIRED_INSTANCE {}
variable MAX_INSTANCE	{}
variable MIN_INSTANCE	{}
variable SCALE_OUT_CPU_PCT_THRESHOLD	{}
variable SCALE_OUT_ACTION_INSTANCE_INCR_COUNT {}
variable SCALE_IN_CPU_PCT_THRESHOLD {}
variable SCALE_IN_ACTION_INSTANCE_DECR_COUNT	{}
variable SOURCE_PORT_RANGE	{}
variable DEST_PORT_RANGE	{}

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
  count = var.PROVISION_SCALESETS ? 1 : 0
  name                = format("%s-lb_pip", var.INSTANCE_NAME)
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.LOCATION
  allocation_method   = "Static"
  sku = var.LB_SKU
}

resource "azurerm_lb" "vset_lb" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  name                = format("%s-lb", var.INSTANCE_NAME)
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
  sku = var.LB_SKU

  frontend_ip_configuration {
    name                 = format("%s-lb_ip", var.INSTANCE_NAME)
    public_ip_address_id = azurerm_public_ip.public[0].id
  }
}

resource "azurerm_lb_backend_address_pool" "vset_lb_bepool" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  name            = format("%s-lb_bepool", var.INSTANCE_NAME)
  loadbalancer_id = azurerm_lb.vset_lb[0].id
}

resource "azurerm_lb_rule" "lb_rule" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  resource_group_name            = var.RESOURCE_GROUP_NAME
  loadbalancer_id                = azurerm_lb.vset_lb[0].id
  name                           = format("%s-lb_rule", var.INSTANCE_NAME)
  protocol                       = var.LB_RULE_PROTOCOL
  frontend_port                  = var.LB_FRONTEND_PORT
  backend_port                   = var.LB_BACKEND_PORT
  frontend_ip_configuration_name = format("%s-lb_ip", var.INSTANCE_NAME)
  backend_address_pool_id       =  azurerm_lb_backend_address_pool.vset_lb_bepool[0].id
}

resource "azurerm_network_security_group" "security_group" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  name                = format("%s-sg", var.INSTANCE_NAME)
  location            = var.LOCATION
  resource_group_name = var.RESOURCE_GROUP_NAME
 }
 
resource "azurerm_network_security_rule" "InboundRule" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  name                        = format("%s-sgrule", var.INSTANCE_NAME)
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = var.SOURCE_PORT_RANGE
  destination_port_range      = var.DEST_PORT_RANGE
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RESOURCE_GROUP_NAME
  network_security_group_name = azurerm_network_security_group.security_group[0].name
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_instance" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  name                            = format("%s-VMSet", var.INSTANCE_NAME)
  resource_group_name             = var.RESOURCE_GROUP_NAME
  location                        = var.LOCATION
  instances						  = var.NBR_OF_INSTANCES
  sku                             = var.VMSET_SKU
  zones  						  = var.AVAILABILITY_ZONE
  scale_in_policy				  = var.SCALE_IN_POLICY
  disable_password_authentication = false
  admin_username                  = var.ADMIN_USERNAME
  admin_password                  = var.ADMIN_PWD
  
 # admin_ssh_key {
  #      username       = var.ADMIN_USERNAME
   #     public_key     = data.azurerm_ssh_public_key.sshkey.public_key
   # }
  
  network_interface {
    name    = format("%s-NI", var.INSTANCE_NAME)
    primary = true
	network_security_group_id = azurerm_network_security_group.security_group[0].id
    ip_configuration {
      name      = "primary"
      primary   = true
      subnet_id = data.azurerm_subnet.subnet.id
	  load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vset_lb_bepool[0].id]
	  public_ip_address {
		name  = format("%s-PIP", var.INSTANCE_NAME)
		}
    }
  }
  
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

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  count = var.PROVISION_SCALESETS ? 1 : 0
  name                = format("%s-autoscaling", var.INSTANCE_NAME)
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.LOCATION
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.linux_instance[0].id

  profile {
    name = "default"

    capacity {
      default = var.DESIRED_INSTANCE
      minimum = var.MIN_INSTANCE
      maximum = var.MAX_INSTANCE
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.linux_instance[0].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.SCALE_OUT_CPU_PCT_THRESHOLD
		metric_namespace = "microsoft.compute/virtualmachinescalesets"
       }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.SCALE_OUT_ACTION_INSTANCE_INCR_COUNT
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.linux_instance[0].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.SCALE_IN_CPU_PCT_THRESHOLD
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.SCALE_IN_ACTION_INSTANCE_DECR_COUNT
        cooldown  = "PT1M"
      }
    }
  }
}

output "azurevmset_lb_ip" {
	value = var.PROVISION_SCALESETS ? azurerm_public_ip.public[0].ip_address : ""
}
