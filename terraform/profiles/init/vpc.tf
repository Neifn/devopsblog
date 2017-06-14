variable "instance_type_nat" {}
variable "image_id_nat" {}

resource "aws_vpc" "custom_vpc" {
  cidr_block       = "${var.vpc_cidr}"

  tags {
    Name = "${var.username}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.custom_vpc.id}"
}

resource "aws_launch_configuration" "nat" {
  name_prefix                 = "${var.username}-${var.environment}-nat"
  image_id                    = "${var.image_id_nat}"
  instance_type               = "${var.instance_type_nat}"
  security_groups             = ["${aws_security_group.nat.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.ssh_key}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "natscaling" {
  name                 = "${var.username}-${var.environment}-natscaling"
  launch_configuration = "${aws_launch_configuration.nat.name}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-public.id}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.username}-${var.environment}-nat"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.custom_vpc.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "eu-west-1a"
}

resource "aws_route_table" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.custom_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }
}

resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

resource "aws_subnet" "eu-west-1a-private" {
    vpc_id = "${aws_vpc.custom_vpc.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "eu-west-1a"
}

