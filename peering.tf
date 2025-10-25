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
