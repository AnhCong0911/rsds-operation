terraform {
  backend "s3" {
    bucket         = "rsds-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "rsds-terraform-locks"
  }
}
