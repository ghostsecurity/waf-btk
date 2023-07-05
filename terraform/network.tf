resource "aws_internet_gateway" "btk" {
  vpc_id = aws_vpc.btk.id

  tags = {
    Name        = "${var.app}-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "btk-public" {
  vpc_id                  = aws_vpc.btk.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_route_table" "btk" {
  vpc_id = aws_vpc.btk.id

  tags = {
    Name        = "${var.app}-route-table-public"
    Environment = var.environment
  }
}

resource "aws_route" "btk" {
  route_table_id         = aws_route_table.btk.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.btk.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.btk-public.*.id, count.index)
  route_table_id = aws_route_table.btk.id
}


resource "aws_security_group" "internal" {
  vpc_id = aws_vpc.btk.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.external.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.btk.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app}-ssh-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "external" {
  vpc_id = aws_vpc.btk.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.ip_allowlist
    ipv6_cidr_blocks = var.ipv6_allowlist
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "${var.app}-inbound-sg"
    Environment = var.environment
  }
}
