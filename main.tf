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
  access_key = "mAKIA6NEWESPLDMMNG36J"
  secret_key = "m8rUGLfqGIwGbVr5K+hVxwSDFG8V26F7s/dfIQvly"
}

resource "aws_cognito_user_pool" "pool" {
  name = "lanchoneteDaRua"
}