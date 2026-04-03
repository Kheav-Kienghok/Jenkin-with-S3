variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
}

variable "bucket_name" {
  description = "Unique S3 bucket name for the static website"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}