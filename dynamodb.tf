################# DynamoDB #################

resource "aws_dynamodb_table" "viewcount-table" {
  name           = "viewcount-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "viewed"
  table_class    = "STANDARD"

  attribute {
    name = "viewed"
    type = "S"
  }

}