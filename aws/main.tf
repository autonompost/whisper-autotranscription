terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # below version is required for spot instance 
      # Error: Error requesting spot instances: UnknownParameter: The parameter NetworkCardIndex is not recognized
      version = "4.10.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "default" {
  key_name   = var.ssh_public_key_name
  public_key = file("../id_rsa.pub") 
}

# instance profile for spot instance
resource "aws_iam_instance_profile" "default" {
  name = "whisper"
  role = aws_iam_role.default.name
}

resource "aws_iam_role" "default" {
  name = "whisper"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "whisper"
  }
}
resource "aws_spot_instance_request" "default" {
  availability_zone = "${var.zone}"
  ami = "${var.os_image}"
  instance_type = "${var.instance_type}"

  #spot_price = "${var.spot_price}"
  wait_for_fulfillment = true
  spot_type = "one-time"
  key_name = "${aws_key_pair.default.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.default.name}"
  
  tags = {
    Name = "whisper"
  }

  root_block_device {
    volume_size = 100
  }

  network_interface {
    network_interface_id = aws_network_interface.default.id
    device_index = 0
  }

  connection {
    user = "debian"
    private_key = "${file("../id_rsa")}"
    host = "${aws_spot_instance_request.default.public_ip}"
  }
}

resource "aws_vpc" "default" {
  cidr_block = "10.10.0.0/16"
                
  tags = {
    Name = "whisper"
  }
}

resource "aws_subnet" "default" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = var.zone
                
  tags = {
    Name = "whisper"
  }
}

resource "aws_network_interface" "default" {
  subnet_id   = aws_subnet.default.id

  tags = {
    Name = "whisper"
  }
}

resource "aws_security_group" "default" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
