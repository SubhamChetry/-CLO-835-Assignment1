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
  key_name   = "docker_key"
  public_key = file("docker_key.pub")
}
resource "aws_instance" "my_amazon" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = false
  user_data = <<EOF
    #!/bin/bash
     sudo yum update -y
     sudo yum install docker -y
     sudo usermod -aG docker ec2-user
     sudo systemctl restart docker
     
  EOF
     
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
  ingress {
    description      = "SSH from everywhere"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from everywhere"
    from_port        = 8082
    to_port          = 8082
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from everywhere"
    from_port        = 8083
    to_port          = 8083
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from everywhere"
    from_port        = 80
    to_port          = 80
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

resource "aws_ecr_repository" "ECR_1" {
    name = "app_repo"
}

resource "aws_ecr_repository" "ECR_2" {
    name = "db_repo"
}