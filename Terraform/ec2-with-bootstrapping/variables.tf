variable "aws_region" {
  default = "us-east-2"
}

variable "ami_id" {
  description = "Amazon Linux 2023 kernel-6.1(64-bit (x86), uefi-preferred)"
  default     = "ami-0c803b171269e2d72"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "public_key_path" {
  description = "~/.ssh/id_rsa.pub"
}
