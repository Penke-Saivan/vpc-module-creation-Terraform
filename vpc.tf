# VPC resource creation
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc.html
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
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
