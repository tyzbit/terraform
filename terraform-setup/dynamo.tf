resource "aws_dynamodb_table" "terraform-locking-table" {
  name           = "tf-locking-table"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge({
    Name      = "Terraform"
    Namespace = "Infrastructure"
  }, local.default_tags)
}

