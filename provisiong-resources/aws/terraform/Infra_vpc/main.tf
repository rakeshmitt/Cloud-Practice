provider "aws" {
	region = local.AWS_REGION
	secret_key = local.AWS_SECRET_KEY
	access_key = local.AWS_ACCESS_KEY
}

module "vpc" {
	source = "./vpc"
	AWS_REGION=local.AWS_REGION
	PROVIDER=local.PROVIDER
	AWS_SECRET_KEY=local.AWS_SECRET_KEY
	AWS_ACCESS_KEY=local.AWS_ACCESS_KEY
	CREATE_VPC = "true"
	VPC_CIDR = "xxxxxxxxxxxxxx"
	VPC_TENANCY = "default"
	ENABLE_DNS_SUPPORT = "true"
	ENABLE_DNS_HOSTNAMES = "true"
	CREATE_IGW = "true"
	CREATE_SG = "true"
	VPC_NAME = "xxxxxx"
	TAGS  = { type = "demo"}
	VPC_TAGS = {}
	PRIVATE_SUBNETS  = ["20.10.15.0/24", "20.10.16.0/24", "20.10.17.0/24"]
	PUBLIC_SUBNETS = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]
	SINGLE_NAT_GATEWAY = "true"
	ONE_NAT_GATEWAY_PER_AZ  = "false"
	AVAILABILITY_ZONES = ["us-east-2a", "us-east-2b", "us-east-2c"]
	MANAGE_DEFAULT_SECURITY_GROUP = "true"
	DEFAULT_SECURITY_GROUP_INGRESS = [{
    from_port   = 8080
    to_port     = 8080
    protocol    = "6"
    cidr_blocks = "0.0.0.0/0"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = "0.0.0.0/0"
  }]
	DEFAULT_SECURITY_GROUP_EGRESS = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
  	DEFAULT_SECURITY_GROUP_NAME = "demo-sg"
	DEFAULT_SECURITY_GROUP_TAGS = {}
	IGW_TAGS = {}
	PUBLIC_SUBNET_SUFFIX = "public"
	PUBLIC_ROUTE_TABLE_TAGS  = {}
	PRIVATE_SUBNET_SUFFIX  = "private"
	PRIVATE_ROUTE_TABLE_TAGS  = {}
	MAP_PUBLIC_IP_ON_LAUNCH = "true"
	PUBLIC_SUBNET_TAGS = {}
	PRIVATE_SUBNET_TAGS = {}
 }

output "vpc_id" {
	value=local.VPC_ID
}

output "security_group_id" {
	value=local.SECURITY_GROUP_ID
}

output "public_subnet_ids" {
	value=local.PUBLIC_SUBNET_IDS
}
 
locals {
	AWS_REGION="us-east-2"
	PROVIDER="AWS"
	AWS_SECRET_KEY="xxxxxxxxxxxxxxxxxxxxxxx"
	AWS_ACCESS_KEY="xxxxxxxxxxxxxxxx"
	VPC_ID = module.vpc.vpc_id
	SECURITY_GROUP_ID = module.vpc.security_group_id
	PUBLIC_SUBNET_IDS = module.vpc.public_subnet_ids
	
}