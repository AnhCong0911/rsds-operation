terraform {
  backend "s3" {
    bucket         = "rsds-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "rsds-terraform-locks"
  }
}
