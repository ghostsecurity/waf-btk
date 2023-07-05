variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "app" {
  type        = string
  description = "Application Name"
  default     = "waf-btk"
}

variable "environment" {
  type        = string
  description = "Application Environment"
  default     = "sandbox"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.55.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  default     = ["10.55.11.0/24", "10.55.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-east-2a", "us-east-2b"]
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-024e6efaf93d85776"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in EC2 instances"
  default     = "change-me"
}

variable "ip_allowlist" {
  description = "Load balancer IP Allowlist"
  default     = ["0.0.0.0/0"]
}

variable "ipv6_allowlist" {
  description = "Load balancer IPv6 Allowlist"
  default     = ["::/0"]
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for ALB"
  default     = "arn:aws:acm:us-east-2:123456789012:certificate/8f44e833-2395-45ac-b7f8-94901a92ce74"
}
