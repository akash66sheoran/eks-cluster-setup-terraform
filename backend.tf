terraform {
  backend "s3" {
    bucket = "robot-shop-tf-remote-backend"
    dynamodb_table = "terraform-state-lock-dynamo"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}