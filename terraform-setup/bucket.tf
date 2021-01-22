resource "aws_s3_bucket" "terraform" {
  bucket = "tyzbit.terraform"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = merge({
    Name      = "Terraform",
    Namespace = "Infrastructure",
  }, local.default_tags)
}

resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket = aws_s3_bucket.terraform.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}