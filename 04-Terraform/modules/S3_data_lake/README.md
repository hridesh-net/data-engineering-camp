# Task: 📦 Terraform S3 Data Lake (Beginner Data Engineering Project)
This project demonstrates how to build a simple, production-style S3 data lake using Terraform, following real-world data engineering practices.

## What This Project Builds
An AWS S3–based data lake with industry-standard zones:
```bash
s3://<bucket-name>-<environment>/
├── raw/
├── processed/
└── analytics/
```
## Features/Things to achieve
- [] Versioning enabled
- [] Server-side encryption (SSE-S3)
- [] Lifecycle rules (move cold data to Glacier)
- [] Modular Terraform design
- [] Fully parameterized using variables

## Data Engineering Concepts Covered
### 1. Data Lake Zones
| Zone | Purpose |
|------|--------|
| raw/ | Original, immutable ingested data |
| processed/ | Cleaned & transformed data |
| analytics/ | Data used for BI, ML & Analytics |

### 2. Storage Optimization
- Hot data → S3 Standard
- Cold data → Glacier (after 30 days)
- Automatic cleanup after 1 year

## Step-by-Step Code Explanation
>**Module: modules/S3_data_lake**

This module is responsible for creating and configuring the S3 data lake.

### 1. Variables (variables.tf)
```hcl
variable "bucket_name" {
  description = "Base name of the S3 data lake bucket"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}
```
These variables allow you to reuse the module across environments.

### 2. Create S3 bucket (main.tf)
```hcl
resource "aws_s3_bucket" "data_lake" {
  bucket        = "${var.bucket_name}-${var.environment}"
  force_destroy = true
}
```
- Bucket name is dynamicaly generated from the variables (to use variables use '${}' to pull the values)

- force_destry = true allows deleting non-empty buckets.

### 3. Enable Versioning
```hcl
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}
```
Versioning protects against accidental deletes and overwrites.

### 4. Enable Encryption
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```
Ensures all data is encrypted at rest.

### 5. Create Data Lake Zones
```hcl
resource "aws_s3_bucket_object" "zones" {
  for_each = toset([
    "raw/",
    "processed/",
    "analytics/"
  ])

  bucket = aws_s3_bucket.data_lake.id
  key    = each.value
}
```

S3 doesn’t have folders — these are zero-byte objects used as prefixes.

### 6. Lifecycle Rules (Glacier + Cleanup)
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "lake_lifecycle" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id     = "move-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
```
Automatically optimizes storage cost over time.

### 7. Module Output
```hcl
output "bucket_name" {
  value = aws_s3_bucket.data_lake.bucket
}
```
Makes the bucket name available to the root module

>**Module: root module**

Go to the terminal and run following commands one by one

```bash
terraform init
terraform plan
terraform apply
```
