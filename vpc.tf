resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-vpc-${local.environment}"
    }
  )
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-igw-${local.environment}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-private-subnet-${local.environment}-${count.index + 1}"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-public-subnet-${local.environment}-${count.index + 1}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      Name = "${var.app_name}-routing-table-public-${local.environment}"
    }
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat-eip" {
  vpc = true

  tags = merge(
    var.tags,
    {
      "Name" = "${var.app_name}-nat-eip-${local.environment}"
    },
  )
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.app_name}-nat-gw-${local.environment}"
    },
  )
}

resource "aws_route_table" "private" {
  count            = length(var.private_subnets)
  vpc_id           = aws_vpc.vpc.id
  propagating_vgws = var.private_propagating_vgws

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${var.app_name}-private-route-table-${local.environment}"
    },
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}
