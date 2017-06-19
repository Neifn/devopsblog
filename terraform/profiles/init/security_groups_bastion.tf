resource "aws_security_group" "bastion_security" {
  name              = "${var.username}-${var.environment}-bastion_security"
  description       = "Allows ssh trafic"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  vpc_id            = "${aws_vpc.custom_vpc.id}"
}

#security group for bastion elb
resource "aws_security_group" "bastion_elb_security" {
  name              = "${var.username}-${var.environment}-bastion_elb_security"
  description       = "Allows ssh trafic to bastion elb"
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
    cidr_blocks     = ["0.0.0.0/0"]
  }
  vpc_id            = "${aws_vpc.custom_vpc.id}"
}
