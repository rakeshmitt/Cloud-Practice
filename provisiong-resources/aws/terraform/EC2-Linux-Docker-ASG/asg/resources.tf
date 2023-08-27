variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable PROVISION_ASG	{}
variable ENABLE_WEB_WAF {}
variable ASG_NAME {}
variable ASG_MAXSIZE {}
variable ASG_MINSIZE {}
variable ASG_DESIREDCAPACITY	{}
variable ASG_SUBNETS_IDS {}
variable LAUNCH_TEMPLATE_ID {}
variable LAUNCH_TEMPLATE_VERSION	{}
variable LB_PORT	{}
variable LB_PROTOCOL {}
variable APP_HOST_PORT	{}
variable VPC_ID 	{}
variable PUBLIC_SUBNET_IDS	{}
variable SECURITY_GROUP_IDS	{}


resource "aws_lb" "main" {
  count = var.PROVISION_ASG ? 1 : 0
  name               = format("%s-lb", var.ASG_NAME)
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.SECURITY_GROUP_IDS
  subnets            = var.PUBLIC_SUBNET_IDS
}

resource "aws_lb_listener" "http" {
  count = var.PROVISION_ASG ? 1 : 0
  load_balancer_arn = aws_lb.main[0].id
  port              = var.LB_PORT
  protocol          = var.LB_PROTOCOL

  default_action {
    target_group_arn = aws_lb_target_group.http[0].id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "http" {
  count = var.PROVISION_ASG ? 1 : 0
  name     = format("%s-lb-tg", var.ASG_NAME)
  port     = var.APP_HOST_PORT
  protocol = var.LB_PROTOCOL
  vpc_id   = var.VPC_ID
  target_type = "instance"
  depends_on = [aws_lb.main]
} 

resource "aws_wafv2_web_acl" "waf" {
  count = var.PROVISION_ASG && var.ENABLE_WEB_WAF ? 1 : 0
  name  = format("%s-waf", var.ASG_NAME)
  scope = "REGIONAL"

  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = format("%s-waf", var.ASG_NAME)
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "waf_association" {
  count = var.PROVISION_ASG && var.ENABLE_WEB_WAF ? 1 : 0
  resource_arn = aws_lb.main[0].arn
  web_acl_arn  = aws_wafv2_web_acl.waf[0].arn
}

resource "aws_autoscaling_group" "asg" {
   count = var.PROVISION_ASG ? 1 : 0
   name                      = var.ASG_NAME
   max_size                  = var.ASG_MAXSIZE
   min_size                  = var.ASG_MINSIZE
   desired_capacity          = var.ASG_DESIREDCAPACITY
   vpc_zone_identifier		 = var.ASG_SUBNETS_IDS
   launch_template {
    id      = var.LAUNCH_TEMPLATE_ID
    version = var.LAUNCH_TEMPLATE_VERSION
  } 
   target_group_arns = [aws_lb_target_group.http[0].arn]
}

output "app_lb_dns_name"{
  value = var.PROVISION_ASG ? aws_lb.main[0].dns_name : ""
}