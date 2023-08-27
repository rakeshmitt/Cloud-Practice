variable AWS_REGION	{}
variable PROVIDER	{}
variable AWS_SECRET_KEY	{}
variable AWS_ACCESS_KEY	{}
variable CREATE_VPC	{}
variable VPC_CIDR	{}
variable VPC_TENANCY	{}
variable ENABLE_DNS_SUPPORT	{}
variable ENABLE_DNS_HOSTNAMES	{}
variable CREATE_IGW	{}
variable CREATE_SG	{}
variable VPC_NAME	{}
variable TAGS {}
variable VPC_TAGS	{}
variable PRIVATE_SUBNETS {}
variable PUBLIC_SUBNETS	{}
variable SINGLE_NAT_GATEWAY	{}
variable ONE_NAT_GATEWAY_PER_AZ {}
variable AVAILABILITY_ZONES	{}
variable MANAGE_DEFAULT_SECURITY_GROUP	{}
variable DEFAULT_SECURITY_GROUP_INGRESS	{}
variable DEFAULT_SECURITY_GROUP_EGRESS	{}
variable DEFAULT_SECURITY_GROUP_NAME	{}
variable DEFAULT_SECURITY_GROUP_TAGS	{}
variable IGW_TAGS	{}
variable PUBLIC_SUBNET_SUFFIX	{}
variable PUBLIC_ROUTE_TABLE_TAGS {}
variable PRIVATE_SUBNET_SUFFIX {}
variable PRIVATE_ROUTE_TABLE_TAGS {}
variable MAP_PUBLIC_IP_ON_LAUNCH	{}
variable PUBLIC_SUBNET_TAGS	{}
variable PRIVATE_SUBNET_TAGS	{}

locals {
  MAX_SUBNET_LENGTH = max(
    length(var.PRIVATE_SUBNETS),
    length(var.PUBLIC_SUBNETS)
  )
  NAT_GATEWAY_COUNT = var.SINGLE_NAT_GATEWAY ? 1 : var.ONE_NAT_GATEWAY_PER_AZ ? length(var.AVAILABILITY_ZONES) : local.MAX_SUBNET_LENGTH
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = var.CREATE_VPC ? 1 : 0

  cidr_block       = var.VPC_CIDR
  instance_tenancy = var.VPC_TENANCY
  enable_dns_support = var.ENABLE_DNS_SUPPORT
  enable_dns_hostnames = var.ENABLE_DNS_HOSTNAMES

  tags = merge(
      {
        "Name" = format("%s", var.VPC_NAME)
      },
      var.TAGS,
      var.VPC_TAGS,
    )
}


##########################
# Security Group
##########################

resource "aws_default_security_group" "this" {
  count = var.CREATE_VPC && var.MANAGE_DEFAULT_SECURITY_GROUP ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  dynamic "ingress" {
    for_each = var.DEFAULT_SECURITY_GROUP_INGRESS
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.DEFAULT_SECURITY_GROUP_EGRESS
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge(
    {
      "Name" = format("%s", var.DEFAULT_SECURITY_GROUP_NAME)
    },
    var.TAGS,
    var.DEFAULT_SECURITY_GROUP_TAGS,
  )
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = var.CREATE_VPC && var.CREATE_IGW && length(var.PUBLIC_SUBNETS) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s", var.VPC_NAME)
    },
    var.TAGS,
    var.IGW_TAGS,
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = var.CREATE_VPC && length(var.PUBLIC_SUBNETS) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = format("%s-${var.PUBLIC_SUBNET_SUFFIX}", var.VPC_NAME)
    },
    var.TAGS,
    var.PUBLIC_ROUTE_TABLE_TAGS,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.CREATE_VPC && var.CREATE_IGW && length(var.PUBLIC_SUBNETS) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = var.CREATE_VPC && local.MAX_SUBNET_LENGTH > 0 ? local.NAT_GATEWAY_COUNT : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      "Name" = var.SINGLE_NAT_GATEWAY ? "${var.VPC_NAME}-${var.PRIVATE_SUBNET_SUFFIX}" : format(
        "%s-${var.PRIVATE_SUBNET_SUFFIX}-%s",
        var.VPC_NAME,
        element(var.AVAILABILITY_ZONES, count.index),
      )
    },
    var.TAGS,
    var.PRIVATE_ROUTE_TABLE_TAGS,
  )
}

################
# Public subnet
################

resource "aws_subnet" "public" {
  count = var.CREATE_VPC && length(var.PUBLIC_SUBNETS) > 0 && (false == var.ONE_NAT_GATEWAY_PER_AZ || length(var.PUBLIC_SUBNETS) >= length(var.AVAILABILITY_ZONES)) ? length(var.PUBLIC_SUBNETS) : 0

  vpc_id                    = aws_vpc.this[0].id
  cidr_block                = element(concat(var.PUBLIC_SUBNETS, [""]), count.index)
  availability_zone         = length(regexall("^[a-z]{2}-", element(var.AVAILABILITY_ZONES, count.index))) > 0 ? element(var.AVAILABILITY_ZONES, count.index) : null
  availability_zone_id      = length(regexall("^[a-z]{2}-", element(var.AVAILABILITY_ZONES, count.index))) == 0 ? element(var.AVAILABILITY_ZONES, count.index) : null
  map_public_ip_on_launch   = var.MAP_PUBLIC_IP_ON_LAUNCH

  tags = merge(
    {
      "Name" = format(
        "%s-${var.PUBLIC_SUBNET_SUFFIX}-%s",
        var.VPC_NAME,
        element(var.AVAILABILITY_ZONES, count.index),
      )
    },
    var.TAGS,
    var.PUBLIC_SUBNET_TAGS,
  )
}

#################
# Private subnet
#################

resource "aws_subnet" "private" {
  count = var.CREATE_VPC && length(var.PRIVATE_SUBNETS) > 0 ? length(var.PRIVATE_SUBNETS) : 0

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = var.PRIVATE_SUBNETS[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.AVAILABILITY_ZONES, count.index))) > 0 ? element(var.AVAILABILITY_ZONES, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.AVAILABILITY_ZONES, count.index))) == 0 ? element(var.AVAILABILITY_ZONES, count.index) : null

  tags = merge(
    {
      "Name" = format(
        "%s-${var.PRIVATE_SUBNET_SUFFIX}-%s",
        var.VPC_NAME,
        element(var.AVAILABILITY_ZONES, count.index),
      )
    },
    var.TAGS,
    var.PRIVATE_SUBNET_TAGS,
  )
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = var.CREATE_VPC && length(var.PRIVATE_SUBNETS) > 0 ? length(var.PRIVATE_SUBNETS) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.SINGLE_NAT_GATEWAY ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = var.CREATE_VPC && length(var.PUBLIC_SUBNETS) > 0 ? length(var.PUBLIC_SUBNETS) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}


output "vpc_id"{
  value = var.CREATE_VPC ? aws_vpc.this[0].id : ""
}

output "security_group_id"{
  value = var.CREATE_VPC && var.MANAGE_DEFAULT_SECURITY_GROUP ? aws_default_security_group.this[0].id : ""
}

output "public_subnet_ids"{
  value = aws_subnet.public.*.id
}
