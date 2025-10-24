# VPC resource creation
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc.html
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  /*   In Terraform, the instance_tenancy argument in an aws_vpc resource controls how EC2 instances are hosted — that is, whether they share physical hardware with other AWS customers or are isolated on dedicated hardware. */
  enable_dns_hostnames = true
  # In Terraform, the enable_dns_hostnames argument in the aws_vpc resource controls whether instances in the VPC receive public DNS hostnames (like ec2-203-0-113-25.compute-1.amazonaws.com) that are resolved to their public IP addresses.

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-VPC-Resource"
    }
  )
  #wanted to give tags in the format- projectName-environment- <resource_name>
}

#Internet Gateway
# https://registry.terraform.io/providers/hashicorp/aws/6.17.0/docs/resources/internet_gateway.html


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-InternetGateway-Resource"
    }
  )
}

#Till now we created VPC and then created Internet Gateway attaching VPC-ID

#Now ---------------------------------------Subnetss-----------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#basic-usage

# ------------------Public Subnet----------------------

resource "aws_subnet" "public" {
  # --------------Count Loop------------------------
  count                   = length(var.public-subnet-cidr-block)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public-subnet-cidr-block[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  #(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
    }
  )
}

#-------------Private subnet------------------

resource "aws_subnet" "private" {
  # --------------Count Loop------------------------
  count             = length(var.private-subnet-cidr-block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private-subnet-cidr-block[count.index]
  availability_zone = local.az_names[count.index]
  # map_public_ip_on_launch = true
  #(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}" # roboshop-dev-private-us-east-1a
    }
  )
}

#------------Database Subnet--------------

resource "aws_subnet" "database" {
  # --------------Count Loop------------------------
  count             = length(var.database-subnet-cidr-block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database-subnet-cidr-block[count.index]
  availability_zone = local.az_names[count.index]
  # map_public_ip_on_launch = true
  #(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}" # roboshop-dev-database-us-east-1a
    }
  )
}


#-----------------------------Route-Table(not Routes)-----------------------

# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table#basic-example

#Public routeTable
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id



  tags = merge(
    var.route_table_tags_public,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-Route-Table-Resource_public"
    }
  )
}

#private routeTable
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id



  tags = merge(
    var.route_table_tags_private,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-Route-Table-Resource_private"
    }
  )
}

#Database routeTable
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id



  tags = merge(
    var.route_table_tags_database,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-Route-Table-Resource_database"
    }
  )
}