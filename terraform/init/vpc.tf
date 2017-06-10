resource "aws_vpc" "custom_vpc" {
  cidr_block       = "${var.vpc_cidr}"

  tags {
    Name = "${var.username}-${var.environment}-vpc"
  }
}
