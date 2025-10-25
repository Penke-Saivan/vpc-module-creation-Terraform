data "aws_availability_zones" "availables" {
  state = "available"
}

data "aws_vpc" "default_Vpc" {
  default = true
}

