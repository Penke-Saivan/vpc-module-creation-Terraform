variable "cidr_block" {
  type = string
}

variable "environment" {
  type = string

}

variable "project" {
  type = string

}

#CIDR variables

variable "public-subnet-cidr-block" {
  type = list(any)

}

variable "private-subnet-cidr-block" {
  type = list(any)

}

variable "database-subnet-cidr-block" {
  type = list(any)

}

#user sends-vpc_tags

variable "vpc_tags" {
  type    = map(any)
  default = {}
}
variable "igw_tags" {
  type    = map(any)
  default = {}
}

variable "public_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "private_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "database_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "route_table_tags_public" {
  type = map(any)
  default = {

  }
}

variable "route_table_tags_private" {
  type = map(any)
  default = {

  }
}

variable "route_table_tags_database" {
  type = map(any)
  default = {

  }
}
variable "eip_tags" {
  type    = map(any)
  default = {}
}
variable "nat_tags" {
  type    = map(any)
  default = {}
}

#- Optional Peering

variable "is_peering_required" {
  type    = bool
  default = true
}
