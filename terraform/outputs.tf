output "node_ip" {
  value = "${aws.instance.public_ip}"
}
