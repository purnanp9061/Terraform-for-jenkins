provider "aws" {
  region = var.region
  access_key = var.access-key
  secret_key = var.secret-key
}

variable "region" {}
variable "access-key" {}
variable "secret-key" {}
variable "vpc-cidr" {}
variable "subnet-cidr" {}
variable "avalibility-zone" {}
variable "all-traffic-cidr" {}
variable "security-group" {}
variable "ami" {}
variable "instance-type" {}
variable "instance-count" {}
variable "associate-PIP" {}
variable "key-value" {}

resource "aws_vpc" "myvpc-1" {
  cidr_block = var.vpc-cidr
  tags = {
    Name="myvpc"
  }
}

resource "aws_subnet" "mysubnet-1" {
  vpc_id = aws_vpc.myvpc-1.id
  cidr_block = var.subnet-cidr
  availability_zone = var.avalibility-zone
  tags = {
    Name="mysubnet"
  }
}

resource "aws_internet_gateway" "mygateway-1" {
  vpc_id = aws_vpc.myvpc-1.id
  tags = {
    Name="mygeteway"
  }
}
 resource "aws_route_table" "myroutetable" {
   vpc_id = aws_vpc.myvpc-1.id
   route {
     cidr_block = var.all-traffic-cidr
     gateway_id = aws_internet_gateway.mygateway-1.id
   }
   tags = {
     Name="myroutetable"
   }
 }

resource "aws_security_group" "mysecurity" {
  name = var.security-group
  vpc_id = aws_vpc.myvpc-1.id

  ingress = [
    for port in [22, 80, 443, 8080, 9000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 resource "aws_route_table_association" "myassociation" {
   route_table_id = aws_route_table.myroutetable.id
   subnet_id      = aws_subnet.mysubnet-1.id
 }

resource "aws_instance" "myinstance" {
  ami = var.ami
  instance_type = var.instance-type
  subnet_id = aws_subnet.mysubnet-1.id
  count = var.instance-count
  associate_public_ip_address = var.associate-PIP
  vpc_security_group_ids = [aws_security_group.mysecurity.id]
  key_name = var.key-value
  user_data = templatefile("./install.sh", {})
  tags = {
    Name="webserver"
  }
}