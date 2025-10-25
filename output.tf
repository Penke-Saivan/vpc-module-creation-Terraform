output "vpc_id" {
  value = aws_vpc.main.id
}

output "eip_public_ip" {
  value = aws_eip.nat.public_ip
}

output "default-vpc-id" {
  value = data.aws_vpc.default_Vpc
}