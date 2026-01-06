# Terraform S3 Remote Backend Setup (AWS)
The main.tf file shows how to create an S3 + DynamoDB backend using a local state, then switch Terraform to use the remote backend.

## Steps to follow:

### Step 1: Start with Local Backend
👉 Comment out the S3 backend block in terraform {}.
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```
Initialize Terraform (local state):
```bash
terraform init
```

Verify the resources we added in terraform
```bash
terraform plan
```

Create S3 bucket and DynamoDB table:
```bash
terraform apply
```

### Step 2: Switch to Remote Backend (S3)
👉 Uncomment / add the S3 backend block:
```hcl
terraform {
  backend "s3" {
    bucket         = "datacamp-diretive-tf-state"
    key            = "tf-infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
```

Re-initialize Terraform and migrate state:
```bash
terraform init -migrate-state
```
Type yes when prompted.
```bash
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes
```
----

## Done ✅
Terraform state is now:
- Stored in S3
- Locked using DynamoDB

Now you can use Terraform normally:
```bash
terraform plan
terraform apply
```