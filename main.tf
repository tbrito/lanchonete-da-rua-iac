terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "lanchonetedarua"

    workspaces {
      name = "lanchonete-cognito-iac"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

### GATEWAY

resource "aws_api_gateway_rest_api" "lanchonetedarua" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "lanchonetedarua"
      version = "1.0"
    }
    paths = {
      "/path2" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })

  name = "lanchonetedarua"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "lanchonetedarua" {
  rest_api_id = aws_api_gateway_rest_api.lanchonetedarua.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.lanchonetedarua.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lanchonetedarua" {
  deployment_id = aws_api_gateway_deployment.lanchonetedarua.id
  rest_api_id   = aws_api_gateway_rest_api.lanchonetedarua.id
  stage_name    = "lanchonetedarua"
}

## VPC

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "lanchonetedarua2"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "lanchonetedarua2" {
  name       = "lanchonetedarua2"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "VPCsLanchonete2"
  }
}

resource "aws_security_group" "rds" {
  name   = "lanchonetedarua2_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lanchonetedarua2_rds"
  }
}

# Instancia do banco
resource "aws_db_instance" "lanchonetedarua2" {
  identifier             = "lanchonetedarua2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.lanchonetedarua2.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.lanchonetedarua2.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "lanchonetedarua2" {
  name   = "lanchonetedarua2"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}