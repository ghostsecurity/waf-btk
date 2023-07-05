resource "aws_vpc" "btk" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.app}-vpc"
    Environment = var.environment
  }
}
