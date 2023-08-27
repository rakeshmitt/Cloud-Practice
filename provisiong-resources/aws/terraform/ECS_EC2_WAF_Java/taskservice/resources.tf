variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable ECS_CLUSTER_NAME {}
variable SECURITY_GROUP_IDS		{}
variable PUBLIC_SUBNET_IDS	{}
variable CONTAINER_NAME {}
variable LB_PORT	{}
variable LB_PROTOCOL {}
variable APP_CONTAINER_PORT {}
variable ECS_SERVICE_NAME	{}
variable ECS_SERVICE_LAUNCH_TYPE	{}
variable SCHEDULING_STRATEGY 	{}
variable APP_DESIRED_CONTAINER_COUNT	{}
variable VPC_ID 	{}
variable ECS_TASK_NAME 	{}
variable ENABLE_WEB_WAF	{}


provider "aws" {
	access_key = var.AWS_ACCESS_KEY
	secret_key = var.AWS_SECRET_KEY
	region = var.AWS_REGION
}

resource "aws_lb" "main" {
  name               = format("%s-%s-lb", var.CONTAINER_NAME, var.ECS_CLUSTER_NAME)
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.SECURITY_GROUP_IDS
  subnets            = var.PUBLIC_SUBNET_IDS
}

resource "aws_lb_listener" "http" {
  
  load_balancer_arn = aws_lb.main.id
  port              = var.LB_PORT
  protocol          = var.LB_PROTOCOL

  default_action {
    target_group_arn = aws_lb_target_group.http.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "http" {
  name     = format("%s-%s-lb-tg", var.CONTAINER_NAME, var.ECS_CLUSTER_NAME)
  port     = var.APP_CONTAINER_PORT
  protocol = var.LB_PROTOCOL
  vpc_id   = var.VPC_ID
  target_type = "instance"
  depends_on = [aws_lb.main]
} 

resource "aws_wafv2_web_acl" "waf" {
  count = var.ENABLE_WEB_WAF ? 1 : 0
  name  = format("%s-%s-waf", var.CONTAINER_NAME, var.ECS_CLUSTER_NAME)
  scope = "REGIONAL"

  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = format("%s-%s-waf", var.CONTAINER_NAME, var.ECS_CLUSTER_NAME)
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "waf_association" {
  count = var.ENABLE_WEB_WAF ? 1 : 0
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.waf[0].arn
}

resource "aws_ecs_service" "application" {
  name            	= var.ECS_SERVICE_NAME
  cluster         	= var.ECS_CLUSTER_NAME
  task_definition 	= var.ECS_TASK_NAME
  launch_type		= var.ECS_SERVICE_LAUNCH_TYPE
  desired_count   	= var.APP_DESIRED_CONTAINER_COUNT
 
  load_balancer {
    target_group_arn = aws_lb_target_group.http.arn
    container_name   = var.CONTAINER_NAME
    container_port   = var.APP_CONTAINER_PORT
  }


  scheduling_strategy = var.SCHEDULING_STRATEGY
  
}

output "app_lb_dns_name"{
  value = aws_lb.main.dns_name
}