provider "aws" {
  region = "us-east-1"  
}
# Creating VPC
resource "aws_vpc" "my-vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"
tags = {
  Name = "VPC-ARCH-02"
}
}
# Creating 1st public subnet 
resource "aws_subnet" "public-SN-1" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block             = "${var.subnet1_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
tags = {
  Name = "PUB-Subnet-1"
}
}
# Creating 2nd pubic subnet 
resource "aws_subnet" "public-SN-2" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block             = "${var.subnet2_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
tags = {
  Name = "PUB-Subnet-2"
}
}
# Creating 1st private subnet 
resource "aws_subnet" "PRIVATE-SN-1" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block             = "${var.subnet3_cidr}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
tags = {
  Name = "PRIVATE-SN-1"
}
}
# Creating 2nd private subnet 
resource "aws_subnet" "PRIVATE-SN-2" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block             = "${var.subnet4_cidr}"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
tags = {
  Name = "PRIVATE-SN-2"
}
}
# Creating Internet Gateway 
resource "aws_internet_gateway" "IGway" {
  vpc_id = "${aws_vpc.my-vpc.id}"
}
# Creating Custum Route Table 
resource "aws_route_table" "Custum" {
  vpc_id = "${aws_vpc.my-vpc.id}"
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.IGway.id}"
  }
tags = {
      Name = "Public-RT"
  }
}
# Associating Route Table
resource "aws_route_table_association" "RT1" {
  subnet_id = "${aws_subnet.public-SN-1.id}"
  route_table_id = "${aws_route_table.Custum.id}"
}
# Associating Route Table
resource "aws_route_table_association" "RT1a" {
  subnet_id = "${aws_subnet.public-SN-2.id}"
  route_table_id = "${aws_route_table.Custum.id}"
}

# Creating Security Group 
resource "aws_security_group" "sg1" {
  vpc_id = "${aws_vpc.my-vpc.id}"
# Inbound Rules
# HTTP access from anywhere
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# HTTPS access from anywhere
ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# SSH access from anywhere
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# Outbound Rules
# Internet access to anywhere
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
tags = {
  Name = "SG-1"
}
}
# Create Network Interface
resource "aws_network_interface" "NWI" {
  subnet_id   = aws_subnet.public-SN-1.id
  private_ips = ["20.0.1.6"]
  security_groups = [aws_security_group.sg1.id]
  tags = {
    Name = "NW-INTERFACE"
  }

  }
# Assign Elastic IP to Network Interface
resource "aws_eip" "elip" {
  vpc      = true
  # network_interface = aws_network_interface.NWI.id
}
resource "aws_eip_association" "eipASO" {
  # network_interface_id = aws_network_interface.NWI.id
  allocation_id        = aws_eip.elip.id
}

# Creating EC2 instance in Public Subnet
resource "aws_instance" "Ubuntu-INS" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.micro"
  count                       = 1
  key_name                    = "jenkins-key-1"
  vpc_security_group_ids      = ["${aws_security_group.sg1.id}"]
  subnet_id                   = "${aws_subnet.public-SN-1.id}"
  associate_public_ip_address = true  # enable auto-assigning public IP
user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2
    systemctl start apache2
    systemctl enable apache2
EOF
tags = {
  Name = "Ubuntu-INS-1"
}

}

resource "aws_s3_bucket" "s3-bkt" {
    bucket = "s3-terra-ub-ins-bup"
    acl = "private"
}
resource "aws_dynamodb_table" "dynDB-TF-statelock" {
  name = "TF-dynDB-2"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    bucket = "s3-terra-ub-ins-bup"
    dynamodb_table = "TF-dynDB-2"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

