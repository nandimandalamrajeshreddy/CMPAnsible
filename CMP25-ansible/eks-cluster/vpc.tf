#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "rama-demo" {
  cidr_block = "10.8.0.0/16"

  tags = map(
    "Name", "terraform-eks-rama-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "rama-demo" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.8.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.rama-demo.id

  tags = map(
    "Name", "terraform-eks-rama-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "rama-demo" {
  vpc_id = aws_vpc.rama-demo.id

  tags = {
    Name = "terraform-eks-rama-demo"
  }
}

resource "aws_route_table" "rama-demo" {
  vpc_id = aws_vpc.rama-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rama-demo.id
  }
}

resource "aws_route_table_association" "rama-demo" {
  count = 2

  subnet_id      = aws_subnet.rama-demo.*.id[count.index]
  route_table_id = aws_route_table.rama-demo.id
}
