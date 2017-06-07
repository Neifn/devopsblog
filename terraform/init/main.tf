# FRAMEWORK BLOCK, PLEASE DON'T DELETE
variable "username" {}
variable "environment" {}
variable "region" {}
variable "aws_profile" {}

terraform {
  backend "s3" {}
}

provider "aws" {
  region                  = "${var.region}"
  profile                 = "${var.aws_profile}"
}
######################################
