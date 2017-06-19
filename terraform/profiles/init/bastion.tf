#introducing variable bastion of list type
variable "bastion" {type="map"}

#calling for teplate files used in user_data
data "template_file" "userdata_bastion" {
  template = "#!/bin/bash\n${file("../../templates/init/userdata_bastion.tpl")}${file("../../templates/init/userdata_common.tpl")}"
  vars {
#assigning values to variables used in user_data by calling list variable keys and selecting appropriate line
    ANSIBLEDNSFQDN               = "${aws_route53_record.dns-ansible-elb.fqdn}"
    SSHRSAAnsibleServerPublicKey = "${var.keys["SSHRSAAnsibleServerPublicKey"]}"
    SSHRSAHostPrivateKey         = "${var.keys["SSHRSAHostPrivateKey"]}"
    SSHRSAAnsibleUserPrivateKey  = "${var.keys["SSHRSAAnsibleUserPrivateKey"]}"
    SSHRSABastionUserPublicKey   = "${var.keys["SSHRSABastionUserPublicKey"]}"
    PLAYBOOK                     = "bastion.yml"
    HOST                         = ""
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

#creating load balancer and rout53 to give bastion static dns address
resource "aws_elb" "bastion-elb" {
  name                = "${var.username}-${var.environment}-bastion-elb"
  subnets             = ["${aws_subnet.eu-west-1a-public.id}"]
  security_groups     = ["${aws_security_group.bastion_elb_security.id}"]
  idle_timeout        = 3600
  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 4
    timeout             = 5
    target              = "tcp:22"
    interval            = 30
  }
}

resource "aws_route53_record" "dns-bastion-elb" {
  zone_id = "${var.dns_zones["zone_id"]}"
  name    = "${var.username}-${var.environment}-bastion.${var.dns_zones["internal"]}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.bastion-elb.dns_name}"]
}


#creating autoscalling group resource in aws which will use our launch configuration and create specified instance
resource "aws_autoscaling_group" "bastionscaling" {
  name                      = "${var.username}-${var.environment}-bastionscaling"
  launch_configuration      = "${aws_launch_configuration.bastion.name}"
  min_size                  = 1
  max_size                  = 1
  vpc_zone_identifier       = ["${aws_subnet.eu-west-1a-public.id}"]
  load_balancers            = ["${aws_elb.bastion-elb.name}"]
  health_check_grace_period = 300
  health_check_type         = "ELB"
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
