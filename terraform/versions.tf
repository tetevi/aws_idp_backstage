terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state on purpose. This is a single-operator destroy/rebuild demo;
  # remote state (S3 + DynamoDB lock) would add bootstrap resources and
  # standing cost for collaboration/durability we don't need here. In real
  # production or anything team-shared, use an S3 backend instead.
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = "aws-idp-backstage"
      ManagedBy = "terraform"
      Demo      = "deploy"
    }
  }
}