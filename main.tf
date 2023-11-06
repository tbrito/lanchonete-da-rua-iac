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
resource "aws_db_instance" "lanchonetedarua2" {
  identifier             = "lanchonetedarua2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.3"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.lanchonetedarua2.name
  vpc_security_group_ids = [aws_security_group.rds2.id]
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

## ECR
resource "aws_ecr_repository" "lanchonetedarua_ecr_repo" {
  name = "app-repo"
}

###ECS
resource "aws_ecs_cluster" "lanchonetedarua_cluster" {
  name = "lanchonetedarua-cluster" 
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-first-task" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "app-first-task",
      "image": "${aws_ecr_repository.lanchonetedarua_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 512         # Specify the memory the container requires
  cpu                      = 256         # Specify the CPU the container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Load Balance
resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-dev" #load balancer name
  load_balancer_type = "application"
  subnets = [ for subnet in module.vpc.public_subnets : subnet ]
  security_groups = ["${aws_security_group.rds2.id}"]
}

#????
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${module.vpc.vpc_id}" # default VPC
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # target group
  }
}

## ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "app-first-service"     # Name the service
  cluster         = "${aws_ecs_cluster.lanchonetedarua_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.app_task.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Reference the target group
    container_name   = "${aws_ecs_task_definition.app_task.family}"
    container_port   = 5000 # Specify the container port
  }

  network_configuration {
    subnets          = ["${aws_db_subnet_group.lanchonetedarua2.id}"]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.rds2.id}"] # Set up the security group
  }
}

#Log the load balancer app URL
output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}