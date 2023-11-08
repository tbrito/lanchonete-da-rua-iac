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

# ###ECS
resource "aws_ecs_cluster" "lanchonetedarua_cluster" {
  name = "lanchonetedarua-cluster" 
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "connect-image-lanchonete-to-ecs-task" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "connect-image-lanchonete-to-ecs-task",
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

# # Load Balance
# resource "aws_alb" "application_load_balancer" {
#   name               = "load-balancer-dev" #load balancer name
#   load_balancer_type = "application"
#   subnets = [ # Referencing the default subnets
#     "${aws_default_subnet.default_subnet_a.id}",
#     "${aws_default_subnet.default_subnet_b.id}"
#   ]
#   # security group
#   security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
# }

# #aws_lb_target_group
# resource "aws_lb_target_group" "target_group" {
#   name        = "target-group"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = "${aws_default_vpc.default_vpc.id}" # default VPC
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = "${aws_alb.application_load_balancer.arn}" #  load balancer
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.target_group.arn}" # target group
#   }
# }

# ## ECS Service
# resource "aws_ecs_service" "app_service" {
#   name            = "app-first-service"     # Name the service
#   cluster         = "${aws_ecs_cluster.lanchonetedarua_cluster.id}"   # Reference the created Cluster
#   task_definition = "${aws_ecs_task_definition.app_task.arn}" # Reference the task that the service will spin up
#   launch_type     = "FARGATE"
#   desired_count   = 3 # Set up the number of containers to 3

#   load_balancer {
#     target_group_arn = "${aws_lb_target_group.target_group.arn}" # Reference the target group
#     container_name   = "${aws_ecs_task_definition.app_task.family}"
#     container_port   = 5000 # Specify the container port
#   }

#   network_configuration {
#     subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
#     assign_public_ip = true     # Provide the containers with public IPs
#     security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
#   }
# }

# #Log the load balancer app URL
# output "app_url" {
#   value = aws_alb.application_load_balancer.dns_name
# }

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
   function_name = aws_lambda_function.generate_token_function.lanchonete_generate_token
   principal     = "events.amazonaws.com"
   source_arn    = "arn:aws:iam::731628207007:role/authentication"
   source_account         = "731628207007"
   function_url_auth_type = "AWS_IAM"
}

## Anexar política do IAM à função do IAM
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

# resource "null_resource" "install_python_dependencies" {
#  provisioner "local-exec" {
#    command = "bash ${path.module}/scripts/create_pkg.sh"
#
#    environment = {
#      source_code_path = "generate_token"
#      function_name    = "lanchonete_generate_token"
#      path_module      = path.module
#      runtime          = "python3.8"
#      path_cwd         = path.cwd
#    }
#  }
# }

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
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.11"
  publish                        = false
  depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role, null_resource.install_python_dependencies]
}
