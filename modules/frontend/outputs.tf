output "cloudfront_domain" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "s3_bucket" {
  value = aws_s3_bucket.static.id
}
