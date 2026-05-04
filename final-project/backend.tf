terraform {
  backend "s3" {
    bucket = "final-tf-state-bucket-v1"
    key = "terraform.tfstate-v1"
    region = "us-west-2"
    dynamodb_table = "final-tf-locks-v1"
    encrypt = true
  }
}