variable "lake_bucket_name" {
  description = "Base name for data lake bucket name"
  type = string
  default = "datacamp_bucket_lake"
}

variable "environment" {
  description = "Environment name (dev, prod, etc..)"
  type = string
  default = "learning"
}