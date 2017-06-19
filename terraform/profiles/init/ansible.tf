variable "ansible" {type="map"}

data "template_file" "userdata_ansible" {
  template = "#!/bin/bash\n${file("../../templates/init/userdata_ansible.tpl")}"
  vars {
    SSHRSAAnsibleServerPrivateKey = "${var.keys["SSHRSAAnsibleServerPrivateKey"]}"
    SSHRSAHostPrivateKey          = "${var.keys["SSHRSAHostPrivateKey"]}"
    SSHRSAAnsibleUserPublicKey    = "${var.keys["SSHRSAAnsibleUserPublicKey"]}"
  }
}

#creating launch configuration for ansible server
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

#creating load balancer and aws route53 to give ansible static dns address
resource "aws_elb" "ansible-elb" {
  name                = "${var.username}-${var.environment}-ansible-elb"
  subnets             = ["${aws_subnet.eu-west-1a-private.id}"]    
  security_groups     = ["${aws_security_group.ansible_elb_security.id}"]
  internal            = true
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

resource "aws_route53_record" "dns-ansible-elb" {
  zone_id = "${var.dns_zones["zone_id"]}"
  name    = "${var.username}-${var.environment}-ansible.${var.dns_zones["internal"]}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ansible-elb.dns_name}"]
}

resource "aws_autoscaling_group" "ansiblescaling" {
  name                      = "${var.username}-${var.environment}-ansiblescaling"
  launch_configuration      = "${aws_launch_configuration.ansible.name}"
  min_size                  = 1
  max_size                  = 1
  vpc_zone_identifier       = ["${aws_subnet.eu-west-1a-private.id}"]
  load_balancers            = ["${aws_elb.ansible-elb.name}"]
  health_check_grace_period = 300
  health_check_type         = "ELB"

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
