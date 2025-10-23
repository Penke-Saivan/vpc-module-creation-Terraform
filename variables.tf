variable "cidr_block" {
  type = string
}

variable "environment" {
  type = string
 
}

variable "project" {
  type = string
 
}

#user sends-vpc_tags

variable "vpc_tags" {
  type = map
  default = {}
}