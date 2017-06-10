variable "instance_type_bastion" {}


resource "aws_launch_configuration" "bastion" {
  name_prefix         = "${var.username}-${var.environment}-bastion"
  image_id            = "${var.image_id}"
  instance_type       = "${var.instance_type_bastion}"
  security_groups     = ["${aws_security_group.bastion_security.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastionscaling" {
  name                 = "${var.username}-${var.environment}-bastionscaling"
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${var.subnet_id}"]

  tags = [ 
    {
      key                 = "Name"
      value               = "${var.username}-${var.environment}-bastion"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}
