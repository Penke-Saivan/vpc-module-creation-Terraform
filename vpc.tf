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

# ----------------------Routes (Not associations with subnet------------------------)

# Public- Route

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route


resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route#gateway_id-1
}

# Now we need NAT Gateway (which requires elastic IP)  routing Private and database subnets

# Elastic IP

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

# Note in doc- EIP may require IGW to exist prior to association. Use depends_on to set an explicit dependency on the IGW.

resource "aws_eip" "nat" {

  domain = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-EIP"
    }
  )
}

#- Now NAT Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  #*****************-Attaching to Public SUbnet ID to go out to the internet via Internet gateway already attached to public subnet

  tags = merge(
    var.nat_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-NAT-Gateway"
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


# Private- Route
# Private egress route through NAT


resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route#gateway_id-1
}

# Database- Route
# Database egress route through NAT


resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route#gateway_id-1
}


#--- Last step to associate subnets with route tables
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

# Public subnets association with public route table 
resource "aws_route_table_association" "public" {
  count          = length(var.public-subnet-cidr-block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnets association with Private route table 
resource "aws_route_table_association" "private" {
  count          = length(var.private-subnet-cidr-block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Database subnets association with Database route table 
resource "aws_route_table_association" "database" {
  count          = length(var.database-subnet-cidr-block)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
