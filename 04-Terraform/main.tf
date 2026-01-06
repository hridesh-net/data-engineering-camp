# setting up cloud provider we will be working with
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

# configuring the Cloud provider
provider "aws" {
    region = "ap-south-1"
}

# creating sample resource
resource "aws_instance" "example" {
    ami = "ami-0c44f651ab5e9285f" # Amazon Linux Image
    instance_type = "t2.micro"
}
