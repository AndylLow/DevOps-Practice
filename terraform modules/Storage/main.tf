terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 Bucket
resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  
  bucket        = each.value.name
  force_destroy = each.value.force_destroy
  
  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}