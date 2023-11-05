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
