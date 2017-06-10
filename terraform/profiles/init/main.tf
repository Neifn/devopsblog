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
variable "image_id" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "ssh_key" {}
variable "vpc_cidr" {}
