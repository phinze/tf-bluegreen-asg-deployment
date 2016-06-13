provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "test" {
  key_name   = "tftest"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_vpc" "example" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"
}

resource "aws_route_table" "example" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.example.id}"
  }
}

resource "aws_security_group" "example" {
  name        = "example_sg_allow_all"
  description = "example_sg_allow_all"
  vpc_id      = "${aws_vpc.example.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_main_route_table_association" "example" {
  vpc_id         = "${aws_vpc.example.id}"
  route_table_id = "${aws_route_table.example.id}"
}

resource "aws_subnet" "example" {
  vpc_id                  = "${aws_vpc.example.id}"
  count                   = 3
  cidr_block              = "${lookup(var.subnets, count.index)}"
  availability_zone       = "${lookup(var.azs, count.index)}"
  map_public_ip_on_launch = true
}
