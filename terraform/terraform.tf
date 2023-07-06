terraform {
  cloud {
    organization = "sp-howard"

    workspaces {
      name = "cloud-resume-back-end"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}