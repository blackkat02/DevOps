terraform {
  backend "s3" {
    bucket         = "borys-bucket-terraform"
    key            = "lesson-10/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
