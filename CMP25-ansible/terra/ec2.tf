resource "aws_instance" "demo" {
  ami                    = "ami-2757f631"
  instance_type          = "t2.small"
  subnet_id              = "id=subnet-041f68cfcdf416981"
  key_name               = "ranjan_KP"                       //Give the existing keypair name present in the AWS.
  iam_instance_profile   = "k8prod_profile"
  vpc_security_group_ids = ["id=sg-0a36415c212b03f9f"]
  tags = {
    Name = "demo"
  }
}

