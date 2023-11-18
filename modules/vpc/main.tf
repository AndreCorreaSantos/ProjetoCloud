resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC Andre"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.region1
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet1" 
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.region2
  tags = {
    Name = "Public Subnet2"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.region1

  tags = {
    Name = "Private Subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.region2

  tags = {
    Name = "Private Subnet2"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "Internet Gateway"
  }
}


# CONECTING PUBLIC SUBNETS TO INTERNET GATEWAY
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_subnet1_rt_a" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2_rt_a" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}




####################################################################
# Elastic IP for NAT gateway
resource "aws_eip" "eip1" {
  depends_on = [aws_internet_gateway.gateway]
  vpc        = true
  tags = {
    Name = "eip1"
  }
}

# NAT gateway for private subnets 
# (for the private subnet to access internet - eg. ec2 instances downloading softwares from internet)
resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet1.id # nat should be in public subnet
  depends_on = [aws_internet_gateway.gateway]

  tags = {
    Name = "nat gateway 1"
  }
}

# Elastic IP for NAT gateway
resource "aws_eip" "eip2" {
  depends_on = [aws_internet_gateway.gateway]
  vpc        = true
  tags = {
    Name = "eip2"
  }
}


# NAT gateway for private subnets 
# (for the private subnet to access internet - eg. ec2 instances downloading softwares from internet)
resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet2.id # nat should be in public subnet
  depends_on = [aws_internet_gateway.gateway]

  tags = {
    Name = "nat gateway 2"
  }
}



# route table - connecting to NAT
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    Name = "private route table 1"
  }
}


# route table - connecting to NAT
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }
  tags = {
    Name = "private route table 2"
  }
}

// Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt_2.id
}
