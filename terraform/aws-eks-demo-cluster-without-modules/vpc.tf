resource "aws_vpc" "eks-vpc" {
  cidr_block         = var.vpc_cidr
  instance_tenancy   = "default"
  enable_dns_support = true


  tags = {
    Name = "eks-vpc"
  }
}

data "aws_availability_zones" "available" {

}

# Create a public subnet in the VPC

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public-subnet-1-cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]


  tags = {
    Name                                        = "eks-public-subnet-1"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public-subnet-2-cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name                                        = "eks-public-subnet-2"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Create a private subnet in the VPC

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.eks-vpc.id
  cidr_block = var.private-subnet-1-cidr

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name                                        = "eks-private-subnet-1"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.eks-vpc.id
  cidr_block = var.private-subnet-2-cidr

  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                                        = "eks-private-subnet-2"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Create a Internet Gateway to connect to the internet from the VPC

resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# Create Elastic IP to attach to NAT Gateway

resource "aws_eip" "my-eks-eip" {

  domain     = "vpc"
  depends_on = [aws_internet_gateway.eks-igw]
}

# Create a NAT Gateway to connect to the internet from the private subnet

resource "aws_nat_gateway" "eks-ngw" {
  allocation_id = aws_eip.my-eks-eip.id
  subnet_id     = aws_subnet.public-subnet-1.id


  tags = {
    Name = "eks-ngw"
  }
  depends_on = [aws_internet_gateway.eks-igw]
}

# Create a route table for the public subnet

resource "aws_route_table" "my-eks-public-route-table" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    Name = "my-eks-public-route-table"
  }
}

resource "aws_route_table" "my-eks-private-route-table" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks-ngw.id
  }

  tags = {
    Name = "my-eks-private-route-table"
  }
}

resource "aws_route_table_association" "public-route-table-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.my-eks-public-route-table.id
}

resource "aws_route_table_association" "public-route-table-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.my-eks-public-route-table.id
}

resource "aws_route_table_association" "private-route-table-1-association" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.my-eks-private-route-table.id
}

resource "aws_route_table_association" "private-route-table-2-association" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.my-eks-private-route-table.id
}

/*
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.eks-vpc.id

  # Inbound rules (Allow ALL traffic for this example - NOT RECOMMENDED FOR PRODUCTION)
  ingress {
    protocol   = "tcp" # All Protocols
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp" # All Protocols
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Outbound rules (Allow all outbound traffic)
  egress {
    protocol   = "tcp" # All protocols
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp" # All protocols
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  tags = {
    Name = "public-nacl"
  }
}

resource "aws_network_acl_association" "public_nacl_association-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl_association" "public_nacl_association-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  network_acl_id = aws_network_acl.public_nacl.id
}
*/