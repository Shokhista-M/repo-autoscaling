terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "029DA-DevOps24"
    
    workspaces {
        prefix = "network-"
    }
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     =  "homework"
}
module "network" {
  source = "./modules/network"
  prefix = var.prefix
  network = {
    "public" = {
      vpc_id            = aws_vpc.main.id
      cidr_blocks       = ["10.0.1.0/24", "10.0.2.0/24"]
      availability_zone = ["us-east-1a", "us-east-1b"]
    }
  }  
    }    