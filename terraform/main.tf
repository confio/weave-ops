data "aws_ami" "node" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["${var.ami_name}"]
  }
}

# Create a subnet to launch our instances into
resource "aws_subnet" "node" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 8, 1)}"
  map_public_ip_on_launch = true

  tags {
    Name = "terraform-${var.name}"
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "node" {
  name        = "mycoind-node"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tendermint RPC/P2P from anywhere
  ingress {
    from_port   = 46656
    to_port     = 46657
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "node" {
  connection {
    # The default username for our AMI
    user = "ubuntu"
  }

  instance_type = "${var.instance_type}"
  ami = "${data.aws_ami.node.id}"

  # The name of our SSH keypair we created above.
  key_name = "${var.key_id}"

  # What permissions to give the machine (eg. sqs access)
  # iam_instance_profile = "${aws_iam_instance_profile.sqs.name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.node.id}"]

  subnet_id = "${aws_subnet.node.id}"

  provisioner "remote-exec" {
    inline = [
      "tendermint init --home /home/ubuntu/.mycoind",
      "sudo systemctl enable mycoind",
      "sudo systemctl enable tendermint"
    ]
  }

  # this is optional, to start a one-node system
  provisioner "remote-exec" {
    inline = [
      "mycoind init ${var.token} ${var.owner}",
      "sudo service tendermint start",
      "sudo service mycoind start"
    ]
  }

  tags {
    Name = "terraform-${var.name}"
  }
}
