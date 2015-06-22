variable "instance_type" {
  default = "t2.micro"
}
variable "azs" {
  default = {
    "0" = "us-west-2a"
    "1" = "us-west-2b"
    "2" = "us-west-2c"
  }
}
variable "region" {
  default = "us-west-2"
}
variable "key_name" {
  default = "tftest"
}
variable "vpc_cidr" {
  default = "10.89.0.0/16"
}
variable "subnets" {
  default = {
    "0" = "10.89.10.0/24"
    "1" = "10.89.11.0/24"
    "2" = "10.89.12.0/24"
  }
}
