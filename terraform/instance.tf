resource "aws_iam_instance_profile" "k8prod_profile" {
  name = "k8prod_profile" //link role mentioned in iam.tf to AWS instance

  role = aws_iam_role.k8_prod.name
}

resource "aws_security_group" "k8_sg" {
  name        = "k8_sg"
  description = "Allowinbound traffic"
  vpc_id      = aws_vpc.k8main.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.publicip
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 10250
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 30000
    to_port     = 32800
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 9600
    to_port     = 9600
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    self      = "true"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    # TLS (change to whatever ports you need)
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_var.route_subnet]
  }

}

resource "aws_instance" "public" {
  ami                    = var.aws_inst_ami
  instance_type          = var.aws_inst_inst_type[1]
  count                  = 1
  subnet_id              = aws_subnet.k8publicsubnet.id // Taking this from output of VPC module
  key_name               = "ranjan_KP"                       //Give the existing keypair name present in the AWS.
  iam_instance_profile   = aws_iam_instance_profile.k8prod_profile.name
  vpc_security_group_ids = [aws_security_group.k8_sg.id]
  //  user_data              = file("copyssh.sh")
  tags = {
    Name = "master${count.index + 1}"
  }
}
resource "aws_instance" "bastionhost" {
  ami                    = var.aws_inst_ami_bastionhost
  instance_type          = var.aws_inst_inst_type[1]
  subnet_id              = aws_subnet.k8publicsubnet.id // Taking this from output of VPC module
  key_name               = "ranjan_KP"                       //Give the existing keypair name present in the AWS.
  iam_instance_profile   = aws_iam_instance_profile.k8prod_profile.name
  vpc_security_group_ids = [aws_security_group.k8_sg.id]
  //user_data              = file("bastionhost.ssh")
  tags = {
    Name = "k8s-bastionhost"
  }
}

