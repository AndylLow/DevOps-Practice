# infra/dev/outputs.tf

output "bucket_info" {
  description = "Information about created buckets"
  value = {
    app_data = {
      name = module.storage.bucket_ids["app-data"]
      arn  = module.storage.bucket_arns["app-data"]
    }
    logs = {
      name = module.storage.bucket_ids["logs"]
      arn  = module.storage.bucket_arns["logs"]
    }
    assets = {
      name = module.storage.bucket_ids["assets"]
      arn  = module.storage.bucket_arns["assets"]
      url  = "https://${module.storage.bucket_domain_names["assets"]}"
    }
  }
}

output "cloudfront_distribution" {
  description = "CloudFront distribution information"
  value = var.enable_cloudfront ? {
    domain_name = aws_cloudfront_distribution.assets[0].domain_name
    hosted_zone_id = aws_cloudfront_distribution.assets[0].hosted_zone_id
  } : null
}

# Export bucket names for use in CI/CD or other automation
output "bucket_names" {
  description = "Bucket names for external reference"
  value = {
    app_data = module.storage.bucket_ids["app-data"]
    logs     = module.storage.bucket_ids["logs"]
    assets   = module.storage.bucket_ids["assets"]
  }
}