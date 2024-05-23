##PRACTICE WITH TERRAFORM: VPC, PUBLIC&PRIVATE SUBNETS, INTERNET GATEWAY, ROUTE TABLE, ELASTIC IP, NAT GATEWAY.


//1. Create VPC:
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "practice-vpc"
  }
}
--------------------------------------------

//2. Create Subnets:

resource "aws_subnet" "besfort_subnet" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "besfort_subnet1" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

---------------------------------------------
//2.1 Create Subnets - attached (2 public & 2 private):
variable "vpc_availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "Practice Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "Practice Private subnet ${count.index + 1}"
  }
}
------------------------------------------------


//3. Internet Gateway:

resource "aws_internet_gateway" "igw_vpc" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "Practice-Internet Gateway"
  }
}
----------------------------------------------------

//4. Route table for public subnet:

resource "aws_route_table" "practice_route_table_public_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc.id
  }
  tags = {
    Name = "Public subnet Route Table"
  }
}

//5. Route table association with public subnet:

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.practice_route_table_public_subnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}
---------------------------------------------------------------
//6. Elastic IP:

resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_vpc]
}

---------------------------------------------------------------

//7. NAT Gateway:

resource "aws_nat_gateway" "practice-nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
  depends_on    = [aws_internet_gateway.igw_vpc]
  tags = {
    Name = "practice-Nat Gateway"
  }
}
-------------------------------------------

//8. Route table for Private subnet:
resource "aws_route_table" "practice_route_table_private_subnet" {
  depends_on = [aws_nat_gateway.practice-nat-gateway]
  vpc_id     = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.practice-nat-gateway.id
  }
  tags = {
    Name = "Private subnet Route Table"
  }
}

---------------------------------------------------------------

//9. Route table association with private subnet:

resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.practicet_route_table_private_subnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}
---------------------------------------------------------------