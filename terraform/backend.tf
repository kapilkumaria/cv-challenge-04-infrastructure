terraform {
  backend "s3" {
    bucket         = "cv-challenge04-terraform-state-backend"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cv-challenge04-terraform-locks"
    encrypt        = true
    profile        = "myAWS"
  }
}