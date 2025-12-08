variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_filename" {
  type = string
  default = "visitor_counter.zip"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "lambda_s3_key" {
  type = string
  default = ""
}
