variable "instance_type_ansible" {}


resource "aws_launch_configuration" "ansible" {
  name_prefix         = "${var.username}-${var.environment}-ansible"
  image_id            = "${var.image_id}"
  instance_type       = "${var.instance_type_ansible}"
  security_groups     = ["${aws_security_group.ansible_security.id}"]
  key_name            = "${var.ssh_key}"

  user_data = "${file("userdata")}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ansiblescaling" {
  name                 = "${var.username}-${var.environment}-ansiblescaling"
  launch_configuration = "${aws_launch_configuration.ansible.name}"
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = ["${var.subnet_id}"]

  lifecycle {
    create_before_destroy = true
  }
}
