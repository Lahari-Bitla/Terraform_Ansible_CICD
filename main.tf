provider "aws" {                                               #provider block
region = "us-east-1"                                           #region where instance need to be created
access_key = "AKIAWVZMPXJHALEPQHGB"                            #access key & secret key through IAM user
secret_key = "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"
}

variable "privatekey" {                                        #pem file is defined by a variable-privatekey
  default = "test-key.pem"
}

resource "aws_security_group" "allow_tls12" {                  #security groups to control the incoming and outgoing traffic for an instance
  name        = "allow_tls12"
  vpc_id      = "vpc-0c531ece6579c3e24"

  ingress {                                                    #inbound rules
    description = "22"                                         #to keep port 22 open that allows ssh connection 
    from_port = "22"                                           #connect to server
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "8080"                                       #to keep port 8080 open                                     
    from_port = "8080"                                         #to allow tomcat connection
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {                                                     #outbound rules
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls12"
  }
}

resource "aws_instance" "web" {                                 #instance creation
  ami           = "ami-0f409bae3775dc8e5"
  instance_type = "t2.micro"
  key_name = "test-key"                                         #key-pair
  vpc_security_group_ids = [aws_security_group.allow_tls12.id]  #sets the security group associated with the instance based on the value of the security_group variable.
 
  tags = {
    Name = "ansible1"                                           #name of the instance
  }

  #Provisioners are used to execute scripts on a local or remote machine as part of resource creation or destruction.

  provisioner "remote-exec" {                                   #The remote-exec provisioner invokes a script on a remote resource after it is created. 
  inline = [                                                    #inline is a list of command strings.
    "echo 'build ssh connection' "                              #echo- to print the given statement
  ]

  connection {                                                  #include a connection block so that Terraform knows how to communicate with the server. 
   host = self.public_ip                                        #The address of the resource to connect to.
   type = "ssh"                                                 #The connection type that should be used.
   user = "ec2-user"                                            #The user that we should use for the connection.
   private_key = file("./test-key.pem")                         #The contents of an SSH key to use for the connection.
  }
  }

   provisioner "local-exec" {                                   #The local-exec provisioner invokes a local executable after a resource is created.
    command = "ansible-playbook -i ${aws_instance.web.public_ip}, --private-key ${var.privatekey} playbook.yml"
  }                                                             #ansible command to run playbook
}


