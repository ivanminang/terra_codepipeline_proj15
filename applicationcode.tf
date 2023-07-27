
# Terraform Block (Define the required provider, his source and the provider version)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
# Provider Block (Define the aws Provider and the region)
provider "aws" {
  region = "us-east-1"
}
# Resources Block (configure all the resources)

# Define the vpc with the cidr
resource "aws_vpc" "MyDemoVPC" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      "Name" = "MyDemoVPC"
    }
}
resource "aws_internet_gateway" "MyDemoIG" {

  vpc_id = aws_vpc.MyDemoVPC.id
  tags = {
    Name = "MyDemoIG"
  }
}

resource "aws_subnet" "WebPublicSubnet" {
  vpc_id = aws_vpc.MyDemoVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
      Name = "DemoSubnet_Public_east1a"
    }

}

resource "aws_subnet" "DBPrivateSubnet" {
  vpc_id = aws_vpc.MyDemoVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
      Name = "DemoSubnet_Private_east1c"
    }
}

resource "aws_subnet" "DBPrivateSubnet1" {
  vpc_id = aws_vpc.MyDemoVPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
      Name = "DemoSubnet_Private_east1b"
    }
}

resource "aws_route_table" "DemoVPC_PublicSubnet_Route_to_IG" {
  vpc_id = aws_vpc.MyDemoVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyDemoIG.id
  }

  tags = {
    Name = "DemoVPC_PublicSubnet_Route_to_IG"
  }
}

resource "aws_route_table_association" "DemoVPC_RouteTableAssociate_Public" {
  subnet_id = aws_subnet.WebPublicSubnet.id
  route_table_id = aws_route_table.DemoVPC_PublicSubnet_Route_to_IG.id

}

# resource "aws_db_subnet_group" "mysqldbsubnet" {
#   name       = "mysqldbsubnet"
#   subnet_ids = [aws_subnet.DBPrivateSubnet.id, aws_subnet.DBPrivateSubnet1.id]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }

# resource "aws_db_instance" "wpdb" {
#   allocated_storage    = 10
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t3.micro"
#   db_name              = "terradbname"
#   username             = var.dbusername
#   password             = var.dbpassword
#   multi_az              = false
#   parameter_group_name = "default.mysql5.7"
#   db_subnet_group_name = aws_db_subnet_group.mysqldbsubnet.name
#   vpc_security_group_ids = [ aws_security_group.dbSG.id ]
#   skip_final_snapshot  = true
# }

resource "aws_instance" "webserver" {
    instance_type = "t2.micro"
    security_groups = [ "${aws_security_group.websrvSG.id}"]
    user_data = filebase64("${path.module}/userdata.sh")
    # depends_on = [
    #   aws_db_instance.wpdb

    # ]
    subnet_id = aws_subnet.WebPublicSubnet.id
    ami = "ami-04823729c75214919"
    key_name = aws_key_pair.terra.key_name
    tags = {
      "name" = "websrv"
    }
}

resource "aws_key_pair" "terra" {
  key_name   = "demokeypair"
  public_key = tls_private_key.demo_key.public_key_openssh
}

resource "local_file" "terra" {
  content  = tls_private_key.demo_key.private_key_pem
  filename = "demokeypair"
}
#--Resource to create a SSH private key using the tls_private_key--
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "websrvSG" {
  description = "security group for my web servers "
  name        = "websrvSG"
  vpc_id      = aws_vpc.MyDemoVPC.id
  lifecycle {
    create_before_destroy = true
  }
  timeouts {
    delete = "2m"
  }

  ingress {
   
    description = "ssh access "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks                = ["0.0.0.0/0"]
  }

  ingress {

    description                = "receives traffic r"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
   cidr_blocks                = ["0.0.0.0/0"]
  }

  ingress {

    description                = "receives traffic "
    from_port                  = 443
    to_port                    = 443
    protocol                   = "tcp"
    cidr_blocks                = ["0.0.0.0/0"] 
  }


  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "websrvSG"
  }
}

resource "aws_security_group" "dbSG" {
  description = "security group for database open to web sg"
  name        = "dbSG"
  vpc_id      = aws_vpc.MyDemoVPC.id
  lifecycle {
    create_before_destroy = true
  }
  timeouts {
    delete = "2m"
  }

  ingress {
   
    description = "ssh access from the vpc (web servers)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description                = "receives traffic from web servers"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    security_groups = [aws_security_group.websrvSG.id] 
  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dbSG"
  }
}


