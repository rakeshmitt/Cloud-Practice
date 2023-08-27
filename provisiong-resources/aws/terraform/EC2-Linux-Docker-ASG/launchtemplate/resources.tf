variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable INSTANCE_NAME	{}
variable SECURITY_GROUP_IDS {}
variable IMAGE_ID	{}
variable INSTANCE_TYPE {}
variable PROVISION_ASG	{}
variable PUBLIC_KEY_NAME	{}
variable ECR_REGISTRY_URL	{}
variable APP_HOST_PORT	{}
variable CONTAINER_PORT	{}
variable CONTAINER_IMAGE	{}
variable USER_DATA_SCRIPT_FILE {}



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


resource "aws_launch_template" "launch_template" {
  count = var.PROVISION_ASG ? 1 : 0
  name_prefix          = format("%s-lt", var.INSTANCE_NAME)
  image_id             = var.IMAGE_ID
  instance_type        = var.INSTANCE_TYPE
  key_name			= var.PUBLIC_KEY_NAME
  vpc_security_group_ids = var.SECURITY_GROUP_IDS
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.INSTANCE_NAME
    }
  }
  
  user_data = data.template_file.user_data.rendered
}

output "launch_template_id"{
  value = var.PROVISION_ASG ? aws_launch_template.launch_template[0].id : ""
}
