# setting up cloud provider we will be working with
terraform {
  # setting up terraform backend to s3
  backend "s3" {
    bucket         = "datacamp-diretive-tf-state"
    key            = "tf-infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# configuring the Cloud provider
provider "aws" {
  region = "ap-south-1"
}

# creating sample resource
# resource "aws_instance" "example" {
#     ami = "ami-0c44f651ab5e9285f" # Amazon Linux Image
#     instance_type = "t2.micro"
# }

# seting up remote backend to AWS S3

# Step 1: Create S3 resource by having Local backend
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "datacamp-diretive-tf-state"
  force_destroy = true
}

resource "aws_dynamodb_table" "terraform" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

