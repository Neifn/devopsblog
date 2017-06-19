resource "aws_security_group" "ansible_security" {
  name              = "${var.username}-${var.environment}-ansible_security"
  description       = "Allows ssh trafic to all instances"
  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_security.id}", "${aws_security_group.ansible_elb_security.id}"]
  }
  vpc_id            = "${aws_vpc.custom_vpc.id}"
}

#security group for ansible elb
resource "aws_security_group" "ansible_elb_security" {
  name              = "${var.username}-${var.environment}-ansible_elb_security"
  description       = "Allows ssh trafic from all instances to ansible"
  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
  }
  vpc_id            = "${aws_vpc.custom_vpc.id}"
}
