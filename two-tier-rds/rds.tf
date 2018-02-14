resource "aws_db_subnet_group" "privaterdssubnet" {
  name       = "privaterdssubnet"
  subnet_ids = ["${aws_subnet.private_subnet.id}", "${aws_subnet.private_subnet2.id}"]

  tags {
    Name = "private RDS Subnet"
  }
}

resource "aws_db_instance" "rds_default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  db_subnet_group_name = "${aws_db_subnet_group.privaterdssubnet.id}"
  engine               = "mysql"
  engine_version       = "5.7.19"
  instance_class       = "db.t2.medium"
  identifier           = "tamrds"
  name                 = "mydb"
  username             = "foo"
  password             = "password"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]

  tags {
    Name = "tamrds"
  }
}