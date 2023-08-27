variable PROVIDER	{}
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable AWS_REGION {}
variable ECS_CLUSTER_NAME {}
variable CONTAINER_NAME {}
variable CONTAINER_DEFINITION_FILE	{}
variable APP_IMAGE {}
variable APP_CPU {}
variable APP_MEMORY {}
variable APP_HOST_PORT {}
variable TASK_VOL_NAME {}
variable APP_CONTAINER_PORT {}
variable ECS_TASK_NAME 	{}
variable TASK_VOL_HOST_PATH {}
variable TASK_NETWORK_MODE {}


provider "aws" {
	access_key = var.AWS_ACCESS_KEY
	secret_key = var.AWS_SECRET_KEY
	region = var.AWS_REGION
}

data "template_file" "container_def" {
  template = file(var.CONTAINER_DEFINITION_FILE)
vars =  { 
  app_name = var.CONTAINER_NAME
  app_image = var.APP_IMAGE
  app_cpu = var.APP_CPU
  app_memory = var.APP_MEMORY
  app_container_Port = var.APP_CONTAINER_PORT
  app_host_port = var.APP_HOST_PORT
  }
 }

resource "aws_ecs_task_definition" "task_def" {
  family                = var.ECS_TASK_NAME
  container_definitions = data.template_file.container_def.rendered

  volume {
    name      = format("%s-storage",var.ECS_TASK_NAME)
    host_path = var.TASK_VOL_HOST_PATH
  }
  network_mode	= var.TASK_NETWORK_MODE 
    
}