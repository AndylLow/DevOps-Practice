# infra/dev/main.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Configure remote backend
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "dev/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = "dev"
      Project       = var.project_name
      ManagedBy     = "terraform"
      Owner         = var.owner
      CostCenter    = var.cost_center
    }
  }
}

# Reference the storage module from external repository
module "storage" {
  source = "git::https://github.com/your-org/terraform-modules.git//storage?ref=v1.0.0"
  
  buckets = {
    # Application data bucket
    app-data = {
      name          = "${var.project_name}-${var.environment}-app-data"
      force_destroy = var.environment == "dev" ? true : false
      
      versioning_enabled = true
      
      encryption = {
        sse_algorithm      = "AES256"
        bucket_key_enabled = true
      }
      
      lifecycle_rules = [
        {
          id      = "cleanup-incomplete-uploads"
          enabled = true
          filter = {
            prefix = "uploads/"
          }
          expiration = {
            days = 7
          }
        }
      ]
      
      tags = {
        Purpose = "application-data"
        Backup  = "required"
      }
    }
    
    # Logs bucket with cost optimization
    logs = {
      name          = "${var.project_name}-${var.environment}-logs"
      force_destroy = true
      
      versioning_enabled = false
      
      lifecycle_rules = [
        {
          id      = "log-retention"
          enabled = true
          
          transitions = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            }
          ]
          
          expiration = {
            days = 365
          }
        }
      ]
      
      tags = {
        Purpose   = "application-logs"
        Retention = "1-year"
      }
    }
    
    # Static assets bucket for web content
    assets = {
      name = "${var.project_name}-${var.environment}-assets"
      
      # Allow public read for static assets
      block_public_access = {
        block_public_acls       = false
        block_public_policy     = false
        ignore_public_acls      = false
        restrict_public_buckets = false
      }
      
      cors_rules = [
        {
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["*"]
          allowed_headers = ["*"]
          max_age_seconds = 3600
        }
      ]
      
      lifecycle_rules = [
        {
          id      = "optimize-old-assets"
          enabled = true
          
          transitions = [
            {
              days          = 60
              storage_class = "STANDARD_IA"
            }
          ]
        }
      ]
      
      tags = {
        Purpose = "static-assets"
        Public  = "true"
      }
    }
  }
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Optional: Create bucket policy for assets bucket
resource "aws_s3_bucket_policy" "assets_public_read" {
  bucket = module.storage.bucket_ids["assets"]
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${module.storage.bucket_arns["assets"]}/*"
      }
    ]
  })
}

# Optional: Create CloudFront distribution for assets
resource "aws_cloudfront_distribution" "assets" {
  count = var.enable_cloudfront ? 1 : 0
  
  origin {
    domain_name = module.storage.bucket_regional_domain_names["assets"]
    origin_id   = "S3-${module.storage.bucket_ids["assets"]}"
    
    s3_origin_config {
      origin_access_identity = ""
    }
  }
  
  enabled             = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${module.storage.bucket_ids["assets"]}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name    = "${var.project_name}-${var.environment}-assets-cdn"
    Purpose = "static-assets-cdn"
  }
}