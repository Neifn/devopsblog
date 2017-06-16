#introducing variable bastion of list type
variable "bastion" {type="map"}

#calling for teplate files used in user_data
data "template_file" "userdata_bastion" {
  template = "#!/bin/bash\n${file("../../templates/init/userdata_bastion.tpl")}${file("../../templates/init/userdata_common.tpl")}"
  vars {
#assigning values to variables used in user_data by calling list variable keys and selecting appropriate line
    SSHRSAAnsibleServerPublicKey = "${var.keys["SSHRSAAnsibleServerPublicKey"]}"
    SSHRSAHostPrivateKey        = "${var.keys["SSHRSAHostPrivateKey"]}"
    SSHRSAAnsibleUserPrivateKey = "${var.keys["SSHRSAAnsibleUserPrivateKey"]}"
  }
}

#creating lauch configuration resource in aws to configure our instance
resource "aws_launch_configuration" "bastion" {
  name_prefix                 = "${var.username}-${var.environment}-bastion"
  image_id                    = "${var.bastion["image_id"]}"
  instance_type               = "${var.bastion["instance_type"]}"
  security_groups             = ["${aws_security_group.bastion_security.id}"]
  key_name                    = "${var.global["ssh_key"]}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.userdata_bastion.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

#creating autoscalling group resource in aws which will use our launch configuration and create specified instance
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
