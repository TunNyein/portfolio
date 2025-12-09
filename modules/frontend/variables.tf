variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type = list(string)
  default = []
}

variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "dns_aliases" {
  type = list(string)
  default = []
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}
