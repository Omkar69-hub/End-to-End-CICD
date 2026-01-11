variable "region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "ap-south-1"
}


variable "public_key" {
    description = "Public key for SSH access to EC2 instances"
    type        = string
}

variable "key_name" {
    description = "Key pair name for EC2 instances"
    type        = string 
} 