# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "tam-workshop"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"


}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "public-subnet1"
  }
}

# Create an private subnets
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2b"

  tags {
    Name = "private-subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-west-2c"

  tags {
    Name = "private-subnet2"
  }
}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-user"
    private_key = "${file("/Users/cormanb/.ssh/aws.pem")}"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "ami-f2d3638a"

  # The name of our SSH keypair already created
  key_name = "aws"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id = "${aws_subnet.public.id}"

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nginx",
      "sudo service nginx start",
    ]
  }
}
