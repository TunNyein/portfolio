#------------------------------------------------------------------------------
# Common Settings
#------------------------------------------------------------------------------
variable "prefix" {
  description = "Prefix used for naming all AWS resources."
  type        = string
  default     = "hellocloud"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for S3, CloudFront, and Route 53 resources."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name to use for authentication."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Root domain name for the website (e.g., tunlab.xyz)."
  type        = string
  default     = "tunlab.xyz"
}

variable "subject_alternative_names" {
  description = "List of SANs (e.g., subdomains) for the ACM certificate."
  type        = list(string)
  default     = ["*.tunlab.xyz"]
}

variable "dns_aliases" {
  type    = list(string)
  default = ["www.tunlab.xyz"]
}

variable "lambda_filename" {
  description = "Filename of the Lambda zip (placed in ./lambda by default)."
  type        = string
  default     = "visitor_counter.zip"
}

variable "lambda_s3_key" {
  description = "Optional S3 key if lambda artifact is stored in S3. Leave empty to use local file."
  type        = string
  default     = ""
}

