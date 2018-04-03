variable "aws_region" {
  description = "region to host the node"
  default = "eu-west-1"
}

variable "instance_type" {
  description = "Instance type"
  default = "t2.small"
}

variable "ami_id" {
  description = "id of the ami to load - default ubuntu 16.04"
  default = "ami-a13266d8"
}

variable "name" {
  description = "Name to assign to launched machine"
  default = "mycoind"
}

variable "cidr_block" {
  description = "cidr block for entire vpc"
  default = "10.42.0.0/16"
}

variable "key_id" {
  description = "ID of key pair for ssh login into web servers"
  default = "terraform"
}

