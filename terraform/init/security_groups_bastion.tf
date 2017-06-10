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
  vpc_id            = "${var.vpc_id}"
}
