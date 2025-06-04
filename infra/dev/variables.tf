# infra/dev/variables.tf

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "myapp"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "dev-team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for assets"
  type        = bool
  default     = false
}