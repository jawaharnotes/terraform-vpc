resource "aws_subnet" "isolated" {
  for_each = local.create_isolated_subnets ? local.isolated_subnets : {}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.env}-isolated-${each.value.az}"
  }
}
