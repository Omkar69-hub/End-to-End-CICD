variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "public_key" {
  description = "Public key for SSH access"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "deployer-key"
}

variable "tf_state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}