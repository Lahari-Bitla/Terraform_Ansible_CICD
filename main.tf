provider "aws" {
region = "us-east-1"
access_key = "AKIAWVZMPXJHALEPQHGB"
secret_key = "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"
}

variable "privatekey" {
  default = "test-key.pem"
}

resource "aws_security_group" "allow_tls12" {
  name        = "allow_tls12"
  vpc_id      = "vpc-0c531ece6579c3e24"

  ingress {
    description = "22"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "8080"
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls12"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0f409bae3775dc8e5"
  instance_type = "t2.micro"
  key_name = "test-key"
  vpc_security_group_ids = [aws_security_group.allow_tls12.id]
 
  tags = {
    Name = "ansible1"
  }

  provisioner "remote-exec" {
  inline = [
    "echo 'build ssh connection' "
  ]

  connection {
   host = self.public_ip
   type = "ssh"
   user = "ec2-user"
   private_key = file("./test-key.pem")
  }
  }

   provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.web.public_ip}, --private-key ${var.privatekey} playbook.yml"
  }
}


