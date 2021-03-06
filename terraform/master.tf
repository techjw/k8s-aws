resource "aws_instance" "k8smaster" {
  ami             = "${var.ami_id}"
  ebs_optimized   = "${var.master_ebs_optimized}"
  instance_type   = "${var.master_type}"
  subnet_id       = "${aws_subnet.subnet_pub1.id}"
  key_name        = "${aws_key_pair.kubernetes.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.kubernetes.name}"
  vpc_security_group_ids      = ["${aws_security_group.kubernetes.id}", "${aws_security_group.kubeapi.id}"]
  associate_public_ip_address = true
  tags {
    environment = "${var.environment}"
    Name    = "${var.project}-master-1"
    project = "${var.project}"
    kube_component = "master"
    KubernetesCluster = "awsk8s"
  }
}
