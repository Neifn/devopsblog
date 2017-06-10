variable "instance_type_ansible" {}
variable "SSHRSAHostPrivateKey" {}

data "template_file" "userdata_ansible" {
  template = "${file("userdata_ansible.tpl")}"
  vars {
    SSHRSAHostPrivateKey = "${var.SSHRSAHostPrivateKey}"
  }
}

resource "aws_launch_configuration" "ansible" {
  name_prefix         = "${var.username}-${var.environment}-ansible"
  image_id            = "${var.image_id}"
  instance_type       = "${var.instance_type_ansible}"
  security_groups     = ["${aws_security_group.ansible_security.id}"]
  key_name            = "${var.ssh_key}"

  user_data           = "${data.template_file.userdata_ansible.rendered}"

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
