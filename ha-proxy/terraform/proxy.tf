terraform {
  required_providers {
	aws = {
	  source  = "hashicorp/aws"
	  version = "~> 3.0"
	}
  }
}

provider "aws" {
  region = var.region
  
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
	name   = "name"
	values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
	name   = "virtualization-type"
	values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "homelab-vpc" {
	cidr_block = "192.168.2.0/24"
	enable_dns_hostnames = true
	
	
}

resource "aws_subnet" "homelab-subnet" {
	vpc_id = aws_vpc.homelab-vpc.id
	availability_zone = "us-east-1a"
	
	cidr_block = "192.168.2.0/24"
}


resource "aws_security_group" "allow_ssh" {
	name = "allow_ssh"
	description = "Allow SSH inbound traffic"
	vpc_id = aws_vpc.homelab-vpc.id
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		from_port = -1
		to_port = -1
		protocol = "icmp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	  }
	
}




resource "aws_internet_gateway" "homelab-gateway" {
	vpc_id = aws_vpc.homelab-vpc.id
	
}


resource "aws_route_table" "homelab-routes" {
	vpc_id = aws_vpc.homelab-vpc.id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.homelab-gateway.id
	}
	
}

resource "aws_route_table_association" "rt-association" {
	subnet_id = aws_subnet.homelab-subnet.id
 	route_table_id = aws_route_table.homelab-routes.id
	
}

resource "aws_eip" "homelab-eip" {
	instance = aws_instance.proxy-node.id
	depends_on = [aws_internet_gateway.homelab-gateway]
}



resource "aws_instance" "proxy-node" {
	instance_type = "t4g.medium"
	ami = data.aws_ami.ubuntu.id
	subnet_id = aws_subnet.homelab-subnet.id
	vpc_security_group_ids = [aws_security_group.allow_ssh.id]
	key_name = "personal"
	tags = {
		Name = "homelab"
	}
}



output "instance-IP" {
	value = aws_eip.homelab-eip.public_ip
}