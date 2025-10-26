output "vpc_id" {
  value = aws_vpc.main.id
}

output "eip_public_ip" {
  value = aws_eip.nat.public_ip
}

output "default-vpc-id" {
  value = data.aws_vpc.default_Vpc
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

# Gives a list
  # + public_subnet_ids   = [
  #     + (known after apply),
  #     + (known after apply),
  #   ]

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id
}
