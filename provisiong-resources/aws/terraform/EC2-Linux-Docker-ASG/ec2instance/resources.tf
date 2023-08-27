#------------------Initialization of Terraform variables----------------------
variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable IMAGE_ID {}
variable INSTANCE_TYPE {}
variable INSTANCE_NAME {}
variable SUBNET_ID {}
variable SECURITY_GROUP_IDS {}
variable PUBLIC_KEY_NAME {}
variable ASSIGN_PUBLIC_IP	{}
variable EC2_MONITORING	{}
variable PROVISION_ASG {}
variable USER_DATA_SCRIPT_FILE	{}
variable ECR_REGISTRY_URL	{}
variable APP_HOST_PORT	{}
variable CONTAINER_PORT	{}
variable CONTAINER_IMAGE	{}

#--------------------------------------------------------------------------------------------
#Providers
#--------------------------------------------------------------------------------------------

provider "aws" {
	access_key = var.AWS_ACCESS_KEY
	secret_key = var.AWS_SECRET_KEY
	region = var.AWS_REGION
}

#--------------------------------------------------------------------------------------------
# AWS Resource Initialization Block for the given Network parameters [Plain vanila Linux-Inst
#--------------------------------------------------------------------------------------------

data "template_file" "user_data" {
  template = base64encode(templatefile(var.USER_DATA_SCRIPT_FILE, 
		{ aws_access_key = var.AWS_ACCESS_KEY,
		  aws_secret_key = var.AWS_SECRET_KEY,
		  aws_region	= var.AWS_REGION,
		  ecr_registry_url = var.ECR_REGISTRY_URL,
		  app_host_port = var.APP_HOST_PORT,
		  container_port = var.CONTAINER_PORT,
		  container_image = var.CONTAINER_IMAGE
		}))
 }


resource "aws_instance" "linux_instance" {
	count = var.PROVISION_ASG ? 0 : 1
	ami= var.IMAGE_ID
	instance_type = var.INSTANCE_TYPE
	monitoring = var.EC2_MONITORING
	vpc_security_group_ids  = var.SECURITY_GROUP_IDS
	subnet_id = var.SUBNET_ID
	key_name = var.PUBLIC_KEY_NAME
	associate_public_ip_address = var.ASSIGN_PUBLIC_IP
	source_dest_check = false
	user_data = data.template_file.user_data.rendered
	tags = {
		"Name" = format("%s-instance", var.INSTANCE_NAME)
	}
}

output "ec2_public_ip"{
  value = var.PROVISION_ASG ? "" : aws_instance.linux_instance[0].public_ip  
}
