data "aws_caller_identity" "current" {}

data "aws_subnet" "subnet1" {
  id = var.subnet_ids[0]
}

data "aws_subnet" "subnet2" {
  id = var.subnet_ids[1]
}

data "aws_subnet" "subnet3" {
  id = var.subnet_ids[2]
}
