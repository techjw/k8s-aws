resource "aws_instance" "k8singress" {
  ami             = "${var.ami_id}"
  ebs_optimized   = "${var.ingress_ebs_optimized}"
  instance_type   = "${var.ingress_type}"
  subnet_id       = "${aws_subnet.subnet_pub1.id}"
  key_name        = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.kubernetes.name}"
  vpc_security_group_ids      = ["${aws_security_group.kubernetes.id}", "${aws_security_group.kubeingress.id}"]
  associate_public_ip_address = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-ingress-1"
    project = "${var.project}"
    kube_component = "ingress"
    KubernetesCluster = "awsk8s"
  }
}
