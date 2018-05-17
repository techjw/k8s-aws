variable "ami_id" { default = "ami-9c56efe3" }

variable "master_type"          { default = "t2.large" }
variable "master_ebs_optimized" { default = false }

variable "worker_type"          { default = "t2.large" }
variable "worker_ebs_optimized" { default = false }
variable "worker_count"         { default = 2 }

variable "ingress_type"           { default = "t2.large" }
variable "ingress_ebs_optimized"  { default = false }

variable "aws_region"   { default = "us-east-1" }
variable "vpc_cidr"     { default = "10.1.0.0/24" }
variable "subnet1_az"   { default = "us-east-1c" }
variable "subnet1_cidr" { default = "10.1.0.0/26" }

variable "local_cidr" { default = "127.0.0.1/32" }
variable "ssh_key"    { default = "../ssh/cluster.pem.pub" }

variable "environment"  { default = "poc" }
variable "project"      { default = "kube" }

variable "aws_access_key" {}
variable "aws_secret_key" {}
