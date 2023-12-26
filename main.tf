terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  
  region="ap-south-1"
  access_key = "AKIARZE4F7RDCDVHDYMQ"
  secret_key = "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"
}

resource "aws_vpc" "sk_vpc"{
    cidr_block="10.0.0.0/16"
    tags={
        Name="sk_vpc"
    }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.sk_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags={
    Name="sk-public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.sk_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags={
    Name="sk-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id=aws_vpc.sk_vpc.id
  tags={
    Name= "igw_sk"
  }
}

resource "aws_route_table" "public-route"{
    vpc_id=aws_vpc.sk_vpc.id
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
    tags={
        Name="public-route"
    }
}

resource "aws_route_table" "private-route"{
    vpc_id=aws_vpc.sk_vpc.id
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags={
        Name="private-route"
    }
}

resource "aws_route_table_association" "public-association" {
  route_table_id = aws_route_table.public-route.id
  subnet_id = aws_subnet.public-subnet.id
}

resource "aws_route_table_association" "private-association" {
  route_table_id = aws_route_table.private-route.id
  subnet_id = aws_subnet.private-subnet.id
}



resource "aws_security_group" "bastion-sg" {
  vpc_id = aws_vpc.sk_vpc.id
  name = "bastion_sg"
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
    ami="ami-0a0f1259dd1c90938"
    subnet_id=aws_subnet.public-subnet.id
    instance_type = "t2.micro"
    key_name="samplekey"
    security_groups = [aws_security_group.bastion-sg.id]
    tags={
        Name="BastionHost"
    }
}

resource "aws_instance" "private-ec2" {
    ami="ami-0a0f1259dd1c90938"
    subnet_id=aws_subnet.private-subnet.id
    instance_type = "t2.micro"
    key_name="samplekey"
    tags={
        Name="ec2-instances"
    }
}
