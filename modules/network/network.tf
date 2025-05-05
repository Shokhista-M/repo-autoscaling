variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}
variable "network" {
    description = "Network configuration"
    type        = map(object({
        vpc_id = string
        cidr_blocks = list(string)
        availability_zone = list(string)
    }))
}
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}
resource "aws_subnet" "public" {
    for_each = var.network
  vpc_id            = each.value.vpc_id
  cidr_block        = each.value.cidr_blocks
  availability_zone = each.value.availability_zone
  tags = {
    Name = "${var.prefix}-{each.key}-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = each.value.vpc_id
  tags = {
    Name = "${var.prefix}-igw"
  }
}
resource "aws_route_table" "public" {
  vpc_id = each.value.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.prefix}-public-rt"
  }
}
resource "aws_route_table_association" "public" {
  for_each = var.network
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}