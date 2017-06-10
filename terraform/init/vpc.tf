resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/17"
  instance_tenancy = "dedicated"

  tags {
    Name = "${var.username}-${var.environment}-vpc"
  }
}
