variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable SECURITY_GROUP_IDS {}
variable ECS_CLUSTER_NAME {}
variable IMAGE_ID	{}
variable INSTANCE_TYPE {}
variable PUBLIC_KEY_NAME	{}
variable ECS_INSTANCE_ROLE_PROFILE_ARN {}
variable USER_DATA_SCRIPT_FILE {}



provider "aws" {
	access_key = var.AWS_ACCESS_KEY
	secret_key = var.AWS_SECRET_KEY
	region = var.AWS_REGION
}


data "template_file" "user_data" {
  template = base64encode(templatefile(var.USER_DATA_SCRIPT_FILE, { ecs_cluster_name = var.ECS_CLUSTER_NAME}))
 }


resource "aws_launch_template" "launch_template" {
  name_prefix          = format("%s-lt", var.ECS_CLUSTER_NAME)
  iam_instance_profile {
	arn = var.ECS_INSTANCE_ROLE_PROFILE_ARN
  }
  image_id             = var.IMAGE_ID
  instance_type        = var.INSTANCE_TYPE
  key_name			= var.PUBLIC_KEY_NAME
  vpc_security_group_ids = var.SECURITY_GROUP_IDS
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = format("%s-lt-instance", var.ECS_CLUSTER_NAME)
    }
  }
  
  user_data = data.template_file.user_data.rendered
}

output "launch_template_id"{
  value = aws_launch_template.launch_template.id
}
