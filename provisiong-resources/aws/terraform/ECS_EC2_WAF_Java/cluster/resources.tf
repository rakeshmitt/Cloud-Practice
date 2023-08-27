variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable ECS_CLUSTER_NAME {}
variable ASG_MAXSIZE {}
variable ASG_MINSIZE {}
variable ASG_DESIREDCAPACITY	{}
variable ASG_ARN {}


provider "aws" {
	access_key = var.AWS_ACCESS_KEY
	secret_key = var.AWS_SECRET_KEY
	region = var.AWS_REGION
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.ECS_CLUSTER_NAME
}

resource "random_integer" "random" {
  min     = 1
  max     = 50000
  keepers = {
    # Generate a new integer each time we switch to a new asg ARN
    auto_scaling_group_arn = var.ASG_ARN
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = format("%s-cp-%v", var.ECS_CLUSTER_NAME, random_integer.random.result)

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.ASG_ARN

    managed_scaling {
      maximum_scaling_step_size = var.ASG_MAXSIZE
      minimum_scaling_step_size = var.ASG_MINSIZE
      status                    = "ENABLED"
      target_capacity           = var.ASG_DESIREDCAPACITY
    }
  }
}


resource "aws_ecs_cluster" "ecs" {
  name = var.ECS_CLUSTER_NAME
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}