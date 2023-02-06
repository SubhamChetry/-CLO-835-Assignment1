provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_key_pair" "my_key" {
  key_name   = "docker.pub"
  public_key = ("ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7bcRsC+AGFiNdiRw42irjkZxgLvKoEhTS808F2Wu33xx4Qhx/x6AnLHfC2FZAfgr/17j62jCNez7xwGYP5fR7mWLRxY7+BICsfe5sdoyPpN7CdI5pzIBJ8lKFdHOZfecMJ0BJIW37eyT/fmTkNhgIPOZwbFwJbzE+vAyrGxOPSJCCCtYbh43yJlFjjAVOcyF0yICFz5gM7Fb9rg0MowEK7BpMstcYtvObcTT083wNlbfSRqUZIt90VYXiT5VnaHKsvq1Ise2GVv2sNgRbONW6GUCvIyKr6XvhL7PG4TDjQf+Ly6+7uqHqjKBP7cSOB8PbWiHM4e8F7IQVVEN2KJHb ec2-user@ip-172-31-78-56.ec2.internal")
}

resource "aws_instance" "my_amazon" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "Assignment 1-Amazon-Linux"
  }
}

resource "aws_security_group" "my_sg" {
  name        = "allow_connection"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "CLO835-sg"


  }


}

resource "aws_eip" "static_eip" {
  instance = aws_instance.my_amazon.id
  tags = {
    "Name" = "Subham-eip"
  }

}

resource "aws_ecr_repository" "Amazon ECR1" {
    name = "assignment 1"
}

resource "aws_ecr_repository" "Amazon ECR2" {
    name = "assignment 2"
}