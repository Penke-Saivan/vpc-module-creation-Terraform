# Terraform AWS VPS

*    VPC
*    IGW
*    2 Public subnets in us-east-1a and us-east-1b AZ
*    2 Private subnets in us-east-1a and us-east-1b AZ
*    2 Database subnets in us-east-1a and us-east-1b AZ
*    Public Route table
*    Private Route table
*    Database Route table
*    EIP for NAT
*    NAT Gateway in public subnet 1a az
*    IGW route is added to public route table
*    NAT gateway route to private and database route tables
*    Route table association with subnets
*    VPC to default VPC peering
*    Public route table to default VPC route
*    Default VPC main route table to created VPC route

## Inputs

* cidr_block - (Required) User must provide CIDR for VPC
* environment - (Required) User must provide environment for VPC
* project - (Required) User must provide project for VPC
* public-subnet-cidr-block - (Required) User must provide the list of cidr 
* private-subnet-cidr-block - (Required) User must provide the list of cidr 
* database-subnet-cidr-block - (Required) User must provide the list of cidr 

## Outputs
* vpc_id - VPC ID 
* eip_public_ip
* default-vpc-id
* public_subnet_ids
* private_subnet_ids
* database_subnet_ids