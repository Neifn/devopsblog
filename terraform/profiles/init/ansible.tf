variable "ansible" {type="map"}

data "template_file" "userdata_ansible" {
  template = "#!/bin/bash\n${file("../../templates/init/userdata_ansible.tpl")}"
  vars {
    SSHRSAAnsibleServerPrivateKey = "${var.keys["SSHRSAAnsibleServerPrivateKey"]}"
    SSHRSAHostPrivateKey          = "${var.keys["SSHRSAHostPrivateKey"]}"
    SSHRSAAnsibleUserPublicKey    = "${var.keys["SSHRSAAnsibleUserPublicKey"]}"
  }
}

resource "aws_launch_configuration" "ansible" {
  name_prefix         = "${var.username}-${var.environment}-ansible"
  image_id            = "${var.ansible["image_id"]}"
  instance_type       = "${var.ansible["instance_type"]}"
  security_groups     = ["${aws_security_group.ansible_security.id}"]
  key_name            = "${var.global["ssh_key"]}"

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
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1a-private.id}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.username}-${var.environment}-ansible"
      propagate_at_launch = true
    },
  ]


  lifecycle {
    create_before_destroy = true
  }
}
