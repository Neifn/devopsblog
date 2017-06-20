variable "nat" {type="map"}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "userdata_nat" {
  template = "#!/bin/bash\n${file("../../templates/init/userdata_nat.tpl")}${file("../../templates/init/userdata_common.tpl")}"
  vars {
    ANSIBLEDNSFQDN               = "${aws_route53_record.dns-ansible-elb.fqdn}"
    SSHRSAAnsibleServerPublicKey = "${var.keys["SSHRSAAnsibleServerPublicKey"]}"
    REGION                       = "${var.region}"
    ROUTETABLEID                 = "${aws_route_table.eu-west-1a-private.id}"
    ELASTICIP                    = "${aws_eip.nat_ip.id}"
    SSHRSAAnsibleUserPrivateKey  = "${var.keys["SSHRSAAnsibleUserPrivateKey"]}" 
    ROLE                         = "nat"
  }
}

resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.username}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.custom_vpc.id}"
}

resource "aws_eip" "nat_ip" {
  vpc      = true
}

resource "aws_iam_instance_profile" "nat_profile" {
  name  = "${var.username}-${var.environment}-nat_profile"
  role = "${aws_iam_role.nat_role.name}"
}

resource "aws_iam_role" "nat_role" {
  name = "${var.username}-${var.environment}-nat_role"
  path = "/"

  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "nat_policy" {
  name = "${var.username}-${var.environment}-nat_policy"
  role = "${aws_iam_role.nat_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstanceAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRouteTables",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_launch_configuration" "nat" {
  name_prefix                 = "${var.username}-${var.environment}-nat"
  image_id                    = "${var.nat["image_id"]}"
  instance_type               = "${var.nat["instance_type"]}"
  security_groups             = ["${aws_security_group.nat.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.global["ssh_key"]}"
  user_data                   = "${data.template_file.userdata_nat.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.nat_profile.id}"

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

    cidr_block = "10.0.0.0/24"
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

    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-1a"
}

resource "aws_route_table" "eu-west-1a-private" {
    vpc_id = "${aws_vpc.custom_vpc.id}"
}


resource "aws_route_table_association" "eu-west-1a-private" {
    subnet_id = "${aws_subnet.eu-west-1a-private.id}"
    route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}
