variable "ami" {
    type = string
    default = "ami-0b5eea76982371e91"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "tags" {
    type = string
    default = "tf.ec2"
}