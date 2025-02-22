variable "environment" {
  type        = string
  description = "The environment (e.g., dev, prod)"
  default     = "dev" // Default to dev for convenience
}

variable "aws_region" {
  type = string
  description = "AWS Region"
  default = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
  default = "ami-0c55t0f18f282d53d"
}

variable "key_name" {
  type = string
  description = " name of the key pair to use for ssh access"
  default = "my-key"
}