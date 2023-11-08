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
  "openapi": "3.0.1",
  "info": {
    "title": "Lanchonete da rua",
    "description": "Api Restful da lanchonete da rua",
    "version": "1.0"
  },
  "servers": [
    {
      "url": "http://192.168.10.20"
    }
  ],
  "paths": {
    "/categorias/": {
      "get": {
        "tags": [
          "categorias"
        ],
        "operationId": "get_categorias_no_parameters",
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "post": {
        "tags": [
          "categorias"
        ],
        "operationId": "post_categorias_no_parameters",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/categorias"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      }
    },
    "/categorias/{categoria_id}": {
      "get": {
        "tags": [
          "categorias"
        ],
        "operationId": "obter um categoria por id",
        "parameters": [
          {
            "name": "categoria_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "put": {
        "tags": [
          "categorias"
        ],
        "operationId": "atualiza um categoria por id",
        "parameters": [
          {
            "name": "categoria_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/categorias"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      },
      "delete": {
        "tags": [
          "categorias"
        ],
        "operationId": "excluir um categoria por id",
        "parameters": [
          {
            "name": "categoria_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/clientes/": {
      "get": {
        "tags": [
          "clientes"
        ],
        "operationId": "Obter todos os clientes",
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "post": {
        "tags": [
          "clientes"
        ],
        "operationId": "Criar um cliente",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/clientes"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      }
    },
    "/clientes/cpf/{cpf}": {
      "get": {
        "tags": [
          "clientes"
        ],
        "operationId": "obter um cliente por cpf",
        "parameters": [
          {
            "name": "cpf",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/clientes/{cliente_id}": {
      "get": {
        "tags": [
          "clientes"
        ],
        "operationId": "obter um cliente por id",
        "parameters": [
          {
            "name": "cliente_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "put": {
        "tags": [
          "clientes"
        ],
        "operationId": "atualiza um cliente por id",
        "parameters": [
          {
            "name": "cliente_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/clientes"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      },
      "delete": {
        "tags": [
          "clientes"
        ],
        "operationId": "excluir um cliente por id",
        "parameters": [
          {
            "name": "cliente_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/pedidos/": {
      "get": {
        "tags": [
          "pedido"
        ],
        "operationId": "Obter lista de pedidos",
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "post": {
        "tags": [
          "pedido"
        ],
        "operationId": "Criar um novo pedido",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/pedido"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      }
    },
    "/pedidos/na-fila": {
      "get": {
        "tags": [
          "pedido"
        ],
        "operationId": "get_fila_atendimento_no_parameters",
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/pedidos/pagamento-webhook": {
      "post": {
        "tags": [
          "pedido"
        ],
        "operationId": "Webhook para atualização do status do pagamento do pedido",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/pagamento"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      }
    },
    "/pedidos/pedidos-nao-finalizados": {
      "get": {
        "tags": [
          "pedido"
        ],
        "operationId": "Obter lista de pedidos não finalizados",
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}": {
      "get": {
        "tags": [
          "pedido"
        ],
        "operationId": "obter um pedido por id",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "description": "Id do Pedido",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Sucesso",
            "content": {}
          },
          "404": {
            "description": "Pedido não encontrado",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}/checkout": {
      "post": {
        "tags": [
          "pedido"
        ],
        "operationId": "Checkout de pedidos",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}/encaminhar-para-entrega": {
      "patch": {
        "tags": [
          "pedido"
        ],
        "operationId": "Encaminhar para entrega ao cliente",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "description": "Id do Pedido",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Sucesso",
            "content": {}
          },
          "400": {
            "description": "Erro ao encaminhar pedido",
            "content": {}
          },
          "404": {
            "description": "Pedido não encontrado",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}/encaminhar-para-pagamento": {
      "patch": {
        "tags": [
          "pedido"
        ],
        "operationId": "Fechar pedido para iniciar processo de pagamento",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "description": "Id do Pedido",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Sucesso",
            "content": {}
          },
          "400": {
            "description": "Erro ao encaminhar pedido",
            "content": {}
          },
          "404": {
            "description": "Pedido não encontrado",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}/finalizar-pedido": {
      "patch": {
        "tags": [
          "pedido"
        ],
        "operationId": "Finalizar pedido já entregue",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "description": "Id do Pedido",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Sucesso",
            "content": {}
          },
          "400": {
            "description": "Erro ao encaminhar pedido",
            "content": {}
          },
          "404": {
            "description": "Pedido não encontrado",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}/itens": {
      "post": {
        "tags": [
          "pedido"
        ],
        "operationId": "Obter todos os itens de um pedido",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/itemPedido"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      }
    },
    "/pedidos/{pedido_id}/itens/{item_pedido_id}": {
      "put": {
        "tags": [
          "pedido"
        ],
        "operationId": "Atualizar um item do pedido",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          },
          {
            "name": "item_pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/itemPedido"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      },
      "delete": {
        "tags": [
          "pedido"
        ],
        "operationId": "excluir um item pedido por id",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          },
          {
            "name": "item_pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/pedidos/{pedido_id}/status-pagamento": {
      "get": {
        "tags": [
          "pedido"
        ],
        "operationId": "Consulta status do pagamento do pedido",
        "parameters": [
          {
            "name": "pedido_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/produtos/": {
      "get": {
        "tags": [
          "produtos"
        ],
        "operationId": "get_produtos_no_parameters",
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "post": {
        "tags": [
          "produtos"
        ],
        "operationId": "post_produtos_no_parameters",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/produtos"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      }
    },
    "/produtos/categoria/{categoria_id}": {
      "get": {
        "tags": [
          "produtos"
        ],
        "operationId": "obter produtos por categoria",
        "parameters": [
          {
            "name": "categoria_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    },
    "/produtos/{produto_id}": {
      "get": {
        "tags": [
          "produtos"
        ],
        "operationId": "obter um produto por id",
        "parameters": [
          {
            "name": "produto_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      },
      "put": {
        "tags": [
          "produtos"
        ],
        "operationId": "atualiza um produto por id",
        "parameters": [
          {
            "name": "produto_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/produtos"
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        },
        "x-codegen-request-body-name": "payload"
      },
      "delete": {
        "tags": [
          "produtos"
        ],
        "operationId": "excluir um produto por id",
        "parameters": [
          {
            "name": "produto_id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "integer"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Success",
            "content": {}
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "categorias": {
        "required": [
          "nome"
        ],
        "type": "object",
        "properties": {
          "nome": {
            "type": "string",
            "description": "nome do categorias"
          }
        }
      },
      "clientes": {
        "required": [
          "cpf",
          "nome",
          "telefone"
        ],
        "type": "object",
        "properties": {
          "nome": {
            "type": "string",
            "description": "nome do cliente"
          },
          "cpf": {
            "type": "string",
            "description": "cpf do cliente"
          },
          "telefone": {
            "type": "string",
            "description": "telefone do cliente"
          }
        }
      },
      "produtos": {
        "required": [
          "categoria_id",
          "descricao",
          "nome"
        ],
        "type": "object",
        "properties": {
          "nome": {
            "type": "string",
            "description": "nome do produto"
          },
          "categoria_id": {
            "type": "integer",
            "description": "Id da Categoria"
          },
          "descricao": {
            "type": "string",
            "description": "descrição do produto"
          }
        }
      },
      "pedido": {
        "type": "object",
        "properties": {
          "cliente_id": {
            "type": "integer",
            "description": "Id do cliente"
          },
          "observacoes": {
            "type": "string",
            "description": "Observações do pedido"
          }
        }
      },
      "itemPedido": {
        "required": [
          "pedido_id",
          "produto_id",
          "quantidade",
          "valor"
        ],
        "type": "object",
        "properties": {
          "pedido_id": {
            "type": "integer",
            "description": "Id do pedido"
          },
          "produto_id": {
            "type": "integer",
            "description": "Id do produto"
          },
          "quantidade": {
            "type": "integer",
            "description": "valor do produto"
          },
          "valor": {
            "type": "number",
            "description": "valor do produto"
          }
        }
      },
      "pagamento": {
        "type": "object",
        "properties": {
          "id": {
            "type": "integer",
            "description": "ID do pagamento"
          },
          "status": {
            "type": "string",
            "description": "Status do pagamento",
            "example": "approved",
            "enum": [
              "approved",
              "rejected"
            ]
          },
          "external_reference": {
            "type": "integer",
            "description": "O ID externo (ID do pedido)"
          }
        }
      }
    },
    "responses": {
      "ParseError": {
        "description": "When a mask can't be parsed",
        "content": {}
      },
      "MaskError": {
        "description": "When any error occurs on mask",
        "content": {}
      }
    }
  },
  "x-original-swagger-version": "2.0"
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

# SSM
resource "aws_ssm_parameter" "postgres_user" {
  name  = "/app/postgres/user"
  type  = "String"
  value = "postgres"
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "/app/postgres/password"
  type  = "String"
  value = "dblanchonetederuapass"
}

resource "aws_ssm_parameter" "postgres_db" {
  name  = "/app/postgres/database"
  type  = "String"
  value = "lanchonetedarua"
}

resource "aws_ssm_parameter" "postgres_uri" {
  name  = "/app/postgres/URI"
  type  = "String"
  value = "postgresql://postgres:dblanchonetederuapass@lanchonetedarua3.co2eflozi4t9.us-east-1.rds.amazonaws.com/postgres"
}

# ECS Task Definition

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task-family"
  network_mode             = "awsvpc"  
  requires_compatibilities = ["FARGATE"]  
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "lanchonetedarua",
    image = "public.ecr.aws/p2v2q2d1/lanchonete-de-rua:latest",
    cpu   = 256,
    memory = 512,
    portMappings = [
      {
        containerPort = 5000
      },
    ],
    secrets = [
      {
        name      = "POSTGRES_USER",
        valueFrom = aws_ssm_parameter.postgres_user.arn
      },
      {
        name      = "POSTGRES_PASSWORD",
        valueFrom = aws_ssm_parameter.postgres_password.arn
      },
      {
        name      = "POSTGRES_DB",
        valueFrom = aws_ssm_parameter.postgres_db.arn
      },
      {
        name      = "DATABASE_URI",
        valueFrom = aws_ssm_parameter.postgres_uri.arn
      }
    ],
    healthCheck = {
      command = ["CMD-SHELL", "curl -f http://localhost:5000/ || exit 1"]
      interval = 30
      timeout = 5
      retries = 3
      startPeriod = 60
    },
  }])
}

resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.lanchonetedarua_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"  
  desired_count   = 1
  network_configuration {
    subnets = [aws_subnet.example.id]
    security_groups = [aws_security_group.example.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "lanchonetedarua"
    container_port   = 5000
  }
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
    action        = "lambda:InvokeFunctionUrl"
    function_name = "lanchonete_generate_token"
    principal     = "events.amazonaws.com"
    source_arn    = "arn:aws:iam::990304834518:role/authentication"
    source_account         = "990304834518"
    function_url_auth_type = "AWS_IAM"
    depends_on                     = [aws_lambda_function.generate_token_function]
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

# LAMBDA GENERATE TOKEN

 data "archive_file" "zip_the_python_code" {
  depends_on  = [null_resource.install_python_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/generate_token/"
  output_path = "${path.module}/lambda_dist_pkg/generate-token.zip"
 }

 resource "aws_lambda_function" "generate_token_function" {
  filename                       = "${path.module}/lambda_dist_pkg/generate-token.zip"
  function_name                  = "lanchonete_generate_token"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.8"
  depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role, null_resource.install_python_dependencies]
 }

# LAMBDA CHECK TOKEN

 resource "null_resource" "create_package" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/create_pkg.sh"
    environment = {
      source_code_path = "check_token"
      function_name    = "check_token"
      path_module      = path.module
      runtime          = "python3.8"
      path_cwd         = path.cwd
    }
  }
}

 data "archive_file" "zip_the_python_code_2" {
  depends_on  = [null_resource.create_package]
  type        = "zip"
  source_dir  = "${path.module}/check_token/"
  output_path = "${path.module}/lambda_dist_pkg/check_token.zip"
 }

  resource "aws_lambda_function" "check_token_function" {
  filename                       = "${path.module}/lambda_dist_pkg/check_token.zip"
  function_name                  = "check_token"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.8"
  depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role, null_resource.install_python_dependencies]
 }

