provider "aws" {
    region = "us-east-1"

     
}

resource "aws_vpc" "tf-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "tf-vpc"
    }  
}

resource "aws_subnet" "tf-subnet" {
    vpc_id = aws_vpc.tf-vpc.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"
    tags = {
      "Name" = "tf-subnet"
    }
}

resource "aws_route_table" "tf-rt" {
    vpc_id = aws_vpc.tf-vpc.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }
    tags ={
      "Name" = "tf-rt"
    }  
}

resource "aws_route_table_association" "tf-rt-association-subnet" {
    route_table_id = aws_route_table.tf-rt.id
    subnet_id = aws_subnet.tf-subnet.id  
}



resource "aws_internet_gateway" "tf-ig" {
    vpc_id = aws_vpc.tf-vpc.id
    tags = {
      "Name" = "tf-ig"
    }  
}

resource "aws_security_group_rule" "tf-sg-inrule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf-sg.id
}

resource "aws_security_group_rule" "tf-sg-outrule" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf-sg.id
}


resource "aws_security_group" "tf-sg" {
    description = "Allow ssh,http,https traffic"
    vpc_id = aws_vpc.tf-vpc.id
    tags = {
      "Name" = "tf-sg"
    }
}

resource "aws_instance" "tf-ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    "Name" = var.tags
  }
  subnet_id = aws_subnet.tf-subnet.id
  associate_public_ip_address = "true"
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  user_data = "${file("userdata.txt")}"  
}
resource "aws_network_interface_sg_attachment" "tf-sg-add" {
  network_interface_id = aws_instance.tf-ec2.primary_network_interface_id
  security_group_id = aws_security_group.tf-sg.id  
}
# # resource "aws_eip" "tf-eip" {
# #   vpc = true
  
# }
# resource "aws_eip_association" "tf-eip-asst" {
#   instance_id = aws_instance.tf-ec2.id
#   allocation_id = aws_eip.tf-eip.id
  
# }
resource "aws_key_pair" "tf-key-pair" {
  key_name = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
  }
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
  }
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
  }

