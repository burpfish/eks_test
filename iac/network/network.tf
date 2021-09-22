# Note: public subnets to keep things simple
data aws_availability_zones azs { }

resource aws_vpc main {
  cidr_block = "10.0.0.0/16"

  tags = var.tags
}

resource aws_subnet main {
  count = 2

  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags              = var.tags
}

resource aws_internet_gateway inet_gw {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource aws_route_table demo {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inet_gw.id
  }

  tags = var.tags
}

resource aws_route_table_association demo {
  count = 2

  subnet_id      = aws_subnet.main.*.id[count.index]
  route_table_id = aws_route_table.demo.id
}