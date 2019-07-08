variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "key_name_test" {}

variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "random_pet" "name" {}

resource "aws_security_group" "Restricted" {
  name        = "${random_pet.name.id}"
  description = "Allow SSH, HTTP and HTTPS."
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = 6
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = 6
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags {
    Name = "pacman"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-5679a229"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = [
    "${aws_security_group.Restricted.id}",
  ]
  key_name = "${var.key_name}"
  tags {
    Name = "${random_pet.name.id}"
  }
  depends_on = [
    "aws_security_group.Restricted",
  ]
}

resource "aws_route53_record" "www" {
  zone_id = "ZEDRX8K9B8W57"
  name    = "pacman.codeherent.co.uk"
  type    = "A"
  ttl     = "300"
  records = [
    "${aws_instance.web.public_ip}",
  ]
  depends_on = [
    "aws_instance.web",
  ]
}

output "ip" {
  value = "${aws_instance.web.public_ip}"
}

output "url" {
  value = "${aws_route53_record.www.name}"
}
