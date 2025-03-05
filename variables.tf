variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami_id" {
  default = "ami-05b10e08d247fb927"
}

variable "instance_type" {
  default = "t2.micro"
}