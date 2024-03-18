terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  required_version = ">= 1.1.0"

  # cloud {
  #   organization = "grupo23postechfiapi"

  #   workspaces {
  #     name = "lanchonete-da-rua-iac"
  #   }
  # }
}

provider "aws" {
  region = "us-east-1"
  access_key = var.client_key
  secret_key = var.client_secret
  # token = "FwoGZXIvYXdzEBYaDHKW3fppRB4R0DBTKiLFAfrgqFScopJRgMEaqqgN2ZLFeaira8w5KgxgthEzHvDoVzGsoYKS9VMX/hX0xYUGpI7m9VmOC8gqofuHG1wE7eNEssaq8GuB58FCCoEJkN6TLYBSuTsnYhNofhwgddUIXpcLvG9Oo1K9jReyetWqKbJVpiMdEtAEEgXJ2kQ699kW46NuYCuwpSHeKZTk5bfgWb0cJF/s4ej3WrRw/kSDEMmwtzCoy36OaYnmOJw5wX7sTuT2Il57UPoqoaGUQHoQVsxLi5K3KKHHm60GMi09YeuOCnoORPLpGfm22r9WsDcTLqnWf0mta7+z9eX0hXlJLzG7a6YtPzwslOI="
}

data "aws_subnet" "subnet1a" {
  id = "subnet-03df6cdb0ce9d859b"
}

data "aws_subnet" "subnet1b" {
  id = "subnet-0e276900afb704937"
}

data "aws_vpc" "default" {
  id = "vpc-04adaa77e36d1d98c"
}

data "aws_caller_identity" "current" {}