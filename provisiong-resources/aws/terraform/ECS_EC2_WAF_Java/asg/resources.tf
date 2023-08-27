variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable ECS_CLUSTER_NAME {}
variable ASG_MAXSIZE {}
variable ASG_MINSIZE {}
variable ASG_DESIREDCAPACITY	{}
variable SUBNETS_IDS {}
variable LAUNCH_TEMPLATE_ID {}
variable LAUNCH_TEMPLATE_VERSION	{}


provider "aws" {
	access_key = var.AWS_ACCESS_KEY
	secret_key = var.AWS_SECRET_KEY
	region = var.AWS_REGION
}


resource "aws_autoscaling_group" "asg" {
   name                      = format("%s-asg", var.ECS_CLUSTER_NAME)
   max_size                  = var.ASG_MAXSIZE
   min_size                  = var.ASG_MINSIZE
   desired_capacity          = var.ASG_DESIREDCAPACITY
   vpc_zone_identifier		 = var.SUBNETS_IDS
   launch_template {
    id      = var.LAUNCH_TEMPLATE_ID
    version = var.LAUNCH_TEMPLATE_VERSION
  }
 tag {
    key                 = "AmazonECSManaged"
	 value               = ""
	 propagate_at_launch = true
 }
  
}

output "asg_arn"{
  value = aws_autoscaling_group.asg.arn
}