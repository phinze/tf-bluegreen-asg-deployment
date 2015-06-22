module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  region = "${var.region}"
  distribution = "trusty"
  instance_type = "${var.instance_type}"
}

resource "aws_elb" "example" {
  name = "terraform-asg-deployment-example"
  subnets = ["${aws_subnet.example.*.id}"]
  security_groups = ["${aws_security_group.example.id}"]
  cross_zone_load_balancing = true
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:80/"
    interval = 5
  }
}

resource "aws_launch_configuration" "blue" {
  image_id = "${module.ami.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.example.id}"]
  user_data = "${file("./boot-blue.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "blue" {
  name = "blue"
  launch_configuration = "${aws_launch_configuration.blue.id}"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_zone_identifier = ["${aws_subnet.example.*.id}"]
  load_balancers = ["${aws_elb.example.name}"]
  max_size = 0
  min_size = 0
}

resource "aws_launch_configuration" "green" {
  image_id = "${module.ami.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.example.id}"]
  user_data = "${file("./boot-green.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "green" {
  name = "green"
  launch_configuration = "${aws_launch_configuration.green.id}"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_zone_identifier = ["${aws_subnet.example.*.id}"]
  load_balancers = ["${aws_elb.example.name}"]
  max_size = 2
  min_size = 2
}

output "dns_name" {
  value = "${aws_elb.example.dns_name}"
}
