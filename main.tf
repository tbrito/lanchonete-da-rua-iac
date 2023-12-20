terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  required_version = ">= 1.1.0"

  # cloud {
  #   organization = "grupo23postech"

  #   workspaces {
  #     name = "iac-lanchonetedarua-database"
  #   }
  # }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA6NEWESPLE5SGOOWO"
  secret_key = "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"
}

data "aws_subnet" "subnet1a" {
  id = "subnet-047634078ec674007"
}

data "aws_subnet" "subnet1b" {
  id = "subnet-0d0e45801c2c36ac7"
}

data "aws_vpc" "default" {
  id = "vpc-016e84561e6555ffe"
}

data "aws_caller_identity" "current" {}