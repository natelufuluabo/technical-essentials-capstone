terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ca-central-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name_1
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name_2
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = var.private_subnet_name_1
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.private_subnet_name_2
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = var.private_subnet_name_3
  }
}

resource "aws_subnet" "private_subnet_4" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.7.0/24"
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.private_subnet_name_4
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.internet_gw_name
  }
}

resource "aws_route_table" "custom_public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

resource "aws_route_table_association" "associate_subnet1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.custom_public_route_table.id
}

resource "aws_route_table_association" "associate_subnet2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.custom_public_route_table.id
}
resource "aws_security_group" "web_layer_security_group" {
  name        = "web-layer-security-group"
  description = "Security group for HTTPS connection from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS connection from anywhere
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "application_layer_security_group" {
  name        = "application-layer-security-group"
  description = "Security group for HTTPS connections within the VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow all HTTPS connections within the VPC
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Allow all outbound traffic within the VPC
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "data_layer_security_group" {
  name        = "data-layer-security-group"
  description = "Security group for MySQL connections within the VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow all MySQL connections within the VPC
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Allow all outbound traffic within the VPC
  }
}

resource "aws_s3_bucket" "rds_backups_bucket" {
  bucket = "rds_backups_bucket"
  force_destroy = true

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Prod"
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "rds_s3_access_policy"
  description = "IAM policy for RDS to access S3 for backups"

  policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:PutObject",
          ],
          "Resource": [
            "arn:aws:s3:::${var.s3_bucket_name}",
            "arn:aws:s3:::${var.s3_bucket_name}/*"
          ]
        }
      ]
    }
  EOF
}

resource "aws_iam_role" "rds_s3_access_role" {
  name = "RDS_S3_Access_Role"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "rds.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.rds_s3_access_role.name
}

