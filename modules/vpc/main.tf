# ---------------- VPC ----------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# ---------------- PUBLIC SUBNETS ----------------
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)
}

# ---------------- PRIVATE SUBNETS ----------------
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 10}.0/24"

  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)
}

# ---------------- INTERNET GATEWAY ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# --------------NAT Gateway-------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  count = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# ---------------- PUBLIC ROUTE TABLE ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

# # ---------------- ROUTE TO INTERNET ----------------
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ---------------- ASSOCIATE PUBLIC SUBNETS ----------------
resource "aws_route_table_association" "public_assoc" {
  count = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}