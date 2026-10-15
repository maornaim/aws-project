terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket       = "maor-devops-tfstate-533267148415"
    key          = "terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

resource "aws_s3_bucket" "terraform_state_new" {
  bucket = "maor-devops-tfstate-533267148415"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_new" {
  bucket = aws_s3_bucket.terraform_state_new.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_new" {
  bucket = aws_s3_bucket.terraform_state_new.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state_new" {
  bucket = aws_s3_bucket.terraform_state_new.id

  versioning_configuration {
    status = "Enabled"
  }
}
