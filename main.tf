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
      name = "lanchonete-da-rua-iac"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

### GATEWAYs

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
# Provide a reference to your default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### VPC
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

resource "aws_db_subnet_group" "lanchonetedarua3" {
  name       = "lanchonetedarua3"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "VPCsLanchonete3"
  }
}

resource "aws_security_group" "rds2" {
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
resource "aws_db_instance" "lanchonetedarua3" {
  identifier             = "lanchonetedarua3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.lanchonetedarua3.name
  vpc_security_group_ids = [aws_security_group.rds2.id]
  parameter_group_name   = aws_db_parameter_group.lanchonetedarua3.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "lanchonetedarua3" {
  name   = "lanchonetedarua3"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# ## ECR
resource "aws_ecr_repository" "lanchonetedarua_ecr_repo" {
  name = "lanchonete-da-rua-ecr"
}

# ECS Cluster
resource "aws_ecs_cluster" "lanchonetedarua_cluster" {
  name = "lanchonetedarua-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task-family"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "lanchonetedarua",
      image = "990304834518.dkr.ecr.us-east-1.amazonaws.com/lanchonete-da-rua:latest",
      cpu   = 256,
      memory = 512,
      ports = [
        {
          containerPort = 5000,
          hostPort      = 5000
        },
      ],
    },
  ])
}

# ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.lanchonetedarua_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "EC2"
  desired_count   = 1
}

# IAM Role for ECS Instance
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_role_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# IAM Instance Profile for ECS
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# ECS Optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"] # Amazon ECS AMI owner ID
}

# EC2 Instance for ECS Cluster
resource "aws_instance" "ecs_host" {
  ami           = data.aws_ami.ecs_optimized.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.lanchonetedarua_cluster.name} >> /etc/ecs/ecs.config
              EOF
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/lanchonetedarua-cluster"
}

# Output the ECS Cluster Name
output "ecs_cluster_name" {
  value = aws_ecs_cluster.lanchonetedarua_cluster.name
}

### Lambda ###
resource "aws_iam_role" "lambda_role" {
name   = "iamRoleLambdaFunctionRole"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Gerenciamento da politica das lambdas"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "lambda:*"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_lambda_permission" "allow_generate_token" {
   statement_id  = "AllowMyroleAuthentication"
   action        = "lambda:InvokeFunction"
   function_name = "lanchonete_generate_token"
   principal     = "events.amazonaws.com"
   source_arn    = "arn:aws:iam::990304834518:role/authentication"
   source_account         = "990304834518"
   function_url_auth_type = "AWS_IAM"
}

## Anexar política do IAM à função do IAM
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "null_resource" "install_python_dependencies" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/create_pkg.sh"

    environment = {
      source_code_path = "generate_token"
      function_name    = "lanchonete_generate_token"
      path_module      = path.module
      runtime          = "python3.8"
      path_cwd         = path.cwd
    }
  }
}

# data "archive_file" "zip_the_python_code" {
#  depends_on  = ["null_resource.install_python_dependencies"]
#  type        = "zip"
#  source_dir  = "${path.module}/generate_token/"
#  output_path = "${path.module}/lambda_dist_pkg/generate-token.zip"
# }

resource "aws_lambda_function" "generate_token_function" {
 # filename                       = "${path.module}/lambda_dist_pkg/generate-token.zip"
  function_name                  = "lanchonete_generate_token"
  role                           = aws_iam_role.lambda_role.arn
 # handler                        = "lambda_function.lambda_handler"
 # runtime                        = "python3.9"
 # publish                        = false
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role, null_resource.install_python_dependencies]
}
