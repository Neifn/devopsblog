variable "bastion" {type="map"}

resource "aws_launch_configuration" "bastion" {
  name_prefix                 = "${var.username}-${var.environment}-bastion"
  image_id                    = "${var.bastion["image_id"]}"
  instance_type               = "${var.bastion["instance_type"]}"
  security_groups             = ["${aws_security_group.bastion_security.id}"]
  key_name                    = "${var.global["ssh_key"]}"
  associate_public_ip_address = true 

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastionscaling" {
  name                 = "${var.username}-${var.environment}-bastionscaling"
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-public.id}"]

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
