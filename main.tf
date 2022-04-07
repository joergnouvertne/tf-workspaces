terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

resource "aws_iam_policy" "s3_policy" {
  name = "s3_policy_for_${var.environment}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:GetObject",
        "Resource" : "*"
    }]
  })
}

