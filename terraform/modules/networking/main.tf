#============================================ Networking Resources ============================================#
# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local variables for cleaner code
locals {
  az_count = min(2, length(data.aws_availability_zones.available.names))
  azs      = slice(data.aws_availability_zones.available.names, 0, local.az_count)
}

# Create VPC for the service
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create public subnets for the service
resource "aws_subnet" "public_subnet" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_cidr_block[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Create private subnets for the service
resource "aws_subnet" "private_subnet" {
  count             = local.az_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_cidr_block[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# Create internet gateway for the service
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-ig"
  }
}

# Create elastic IPs for NAT Gateways, one per AZ for high availability
resource "aws_eip" "nat_eip" {
  count  = var.enable_nat_high_availability ? local.az_count : 1
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Create NAT Gateways for the service
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_nat_high_availability ? local.az_count : 1
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "${var.project_name}-nat-gateway-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Create the public route table for the service
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public_rt_assoc" {
  count          = local.az_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create private route tables, one per AZ for high availability
resource "aws_route_table" "private_rt" {
  count  = var.enable_nat_high_availability ? local.az_count : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.enable_nat_high_availability ? aws_nat_gateway.nat_gateway[count.index].id : aws_nat_gateway.nat_gateway[0].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

# Associate private route tables with private subnets
resource "aws_route_table_association" "private_rt_assoc" {
  count          = local.az_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = var.enable_nat_high_availability ? aws_route_table.private_rt[count.index].id : aws_route_table.private_rt[0].id
}

# Create database subnets (isolated)
resource "aws_subnet" "database_subnet" {
  count             = var.create_database_subnets ? local.az_count : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.db_cidr_block[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.project_name}-database-subnet-${count.index + 1}"
  }
}

# Database route table (no internet access)
resource "aws_route_table" "database_rt" {
  count  = var.create_database_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-database-rt"
  }
}

resource "aws_route_table_association" "database_rt_assoc" {
  count          = var.create_database_subnets ? local.az_count : 0
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database_rt[0].id
}
