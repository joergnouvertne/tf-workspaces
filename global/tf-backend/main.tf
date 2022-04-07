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

# Create KMS key to encrypt S3 buckets

resource "aws_kms_key" "tf_state_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "tf_state_key" {
  name          = "alias/jn-bucket-key"
  target_key_id = aws_kms_key.tf_state_key.key_id
}

# Create the TF backend S3 bucket (private, versioning, encrypted)

resource "aws_s3_bucket" "tf_state" {
  bucket = "jn-terraform-remote-states"

  tags = {
    Name = "Terraform Remote States"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf_state_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


