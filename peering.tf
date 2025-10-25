resource "aws_vpc_peering_connection" "default" {
  count       = var.is_peering_required ? 1 : 0
  peer_vpc_id = data.aws_vpc.default_Vpc.id #acceptor
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-default-peering-request"
    }
  )
}
#  module.vpc.aws_vpc_peering_connection.default[0] will be created

# route --for paving a road from may be roboshop vpc to default vpc 

resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default_Vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[0].id
}

# route --for paving a road from  default vpc to roboshop vpc  

resource "aws_route" "default_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_vpc.default_Vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block #var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[0].id
}
