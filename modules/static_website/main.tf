# --------------------------------------------------------------
# ACM Certificate (for CloudFront – ACM in us-east-1 is required)
# --------------------------------------------------------------
resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

locals {
  domain_validations = [
    for dvo in aws_acm_certificate.this.domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ]
}

resource "aws_route53_record" "validation" {
  count           = length(local.domain_validations)
  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = local.domain_validations[count.index].name
  type            = local.domain_validations[count.index].type
  ttl             = 300
  records         = [local.domain_validations[count.index].value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

# --------------------------------------------------------------
# S3 Bucket for Static Website
# --------------------------------------------------------------
resource "aws_s3_bucket" "static" {
  bucket        = "${var.prefix}-static-web-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "static_block" {
  bucket                  = aws_s3_bucket.static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------------------------------
# S3 Bucket Policy (Required for CloudFront OAC)
# --------------------------------------------------------------
resource "aws_s3_bucket_policy" "static_policy" {
  bucket = aws_s3_bucket.static.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontRead"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static.arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.distribution.arn
          }
        }
      }
    ]
  })
}

# --------------------------------------------------------------
# CloudFront OAC
# --------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.prefix}-oac"
  description                       = "Origin Access Control for ${aws_s3_bucket.static.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --------------------------------------------------------------
# CloudFront Distribution
# --------------------------------------------------------------
resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name              = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id                = "${var.prefix}-oac"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.prefix}-oac"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.this.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = var.dns_aliases

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# --------------------------------------------------------------
# Route53 Alias (Custom Domain → CloudFront)
# --------------------------------------------------------------
resource "aws_route53_record" "dns_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_aliases[0]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
