terraform {
  cloud {
    organization = "sp-howard"

    workspaces {
      name = "cloud-resume-challenge-backend"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}