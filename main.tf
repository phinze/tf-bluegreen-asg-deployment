module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  region = "us-west-2"
  distribution = "trusty"
  instance_type = "${var.instance_type}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  count = 3
  cidr_block = "${lookup(var.subnets, count.index)}"
  availability_zone = "${lookup(var.azs, count.index)}"
  map_public_ip_on_launch = true
}

resource "aws_elb" "ourapp" {
  name = "terraform-asg-deployment-example"
  subnets = ["${aws_subnet.main.*.id}"]
  cross_zone_load_balancing = true
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  tags {
    Name = "testyay"
  }
}

resource "aws_launch_configuration" "blue" {
  image_id = "${module.ami.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "tftest"
  user_data = "${file("./boot.sh")}"
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "blue" {
  name = "blue"
  launch_configuration = "${aws_launch_configuration.blue.id}"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_zone_identifier = ["${aws_subnet.main.*.id}"]
  load_balancers = ["${aws_elb.ourapp.name}"]
  max_size = 0
  min_size = 0
}

resource "aws_launch_configuration" "green" {
  image_id = "${module.ami.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "tftest"
  user_data = "${file("./boot.sh")}"
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "green" {
  name = "green"
  launch_configuration = "${aws_launch_configuration.green.id}"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_zone_identifier = ["${aws_subnet.main.*.id}"]
  load_balancers = ["${aws_elb.ourapp.name}"]
  max_size = 1
  min_size = 1
}
