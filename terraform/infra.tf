provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
      environment = "${var.environment}"
      Name    = "${var.project}-${var.environment}"
      project = "${var.project}"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-igw"
    project = "${var.project}"
  }
}

resource "aws_subnet" "subnet_pub1" {
  availability_zone = "${var.subnet1_az}"
  cidr_block        = "${var.subnet1_cidr}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-subnet-pub1"
    project = "${var.project}"
  }
}

resource "aws_route_table" "subnet_pub1" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc.id}"
  }
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-subnet-pub1-rt"
    project = "${var.project}"
  }
}

resource "aws_route_table_association" "subnet_pub1" {
  subnet_id      = "${aws_subnet.subnet_pub1.id}"
  route_table_id = "${aws_route_table.subnet_pub1.id}"
}

resource "aws_security_group" "kubernetes" {
  name        = "${var.project}-${var.environment}-sg"
  description = "Allow standard access to Kubernetes cluster nodes"
  vpc_id      = "${aws_vpc.vpc.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-${var.environment}-sg"
    project = "${var.project}"
  }
}

resource "aws_security_group" "kubeapi" {
  name        = "${var.project}api-${var.environment}-sg"
  description = "Allow access to Kubernetes API"
  vpc_id      = "${aws_vpc.vpc.id}"
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}"]
  }
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}api-${var.environment}-sg"
    project = "${var.project}"
  }
}

resource "aws_security_group" "kubeingress" {
  name        = "${var.project}ingress-${var.environment}-sg"
  description = "Allow access to Kubernetes Ingress"
  vpc_id      = "${aws_vpc.vpc.id}"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}", "${var.local_cidr}"]
  }
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}ingress-${var.environment}-sg"
    project = "${var.project}"
  }
}

resource "aws_key_pair" "kubernetes" {
  key_name = "${var.project}-${var.environment}-key"
  public_key = "${file("${path.module}/${var.ssh_key}")}"
}

resource "aws_iam_role" "kubernetes" {
  name = "${var.project}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "kubeapi" {
  name = "${var.project}api-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kubernetes" {
  name = "${var.project}-policy"
  role = "${aws_iam_role.kubernetes.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "autoscaling:Describe*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "ec2:Describe*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "elasticloadbalancing:Describe*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": ["s3:Get*", "s3:List*"],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::kubernetes-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kubeapi" {
  name = "${var.project}api-policy"
  role = "${aws_iam_role.kubeapi.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "autoscaling:Describe*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "elasticloadbalancing:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::kubernetes-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kubernetes" {
  name = "${var.project}-instance-profile"
  role = "${aws_iam_role.kubernetes.name}"
}

resource "aws_iam_instance_profile" "kubeapi" {
  name = "${var.project}api-instance-profile"
  role = "${aws_iam_role.kubeapi.name}"
}
