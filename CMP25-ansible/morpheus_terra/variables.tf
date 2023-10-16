# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
variable "vpc_id" {
  description = "The VPC will be used for creating EC2 instance"
  default     = "vpc-7702151f"
}
variable "aws_inst_ami_host" {
  description = "The AMI will be used for creating EC2 instance"
  default     = "ami-02d55cb47e83a99a0"
}
variable "aws_instance_name" {
  description = "The AMI will be used for creating EC2 instance"
  default     = "morpheus-instance-name"
}
variable "aws_SG_name" {
  description = "The AMI will be used for creating EC2 instance"
  default     = "morpheus-SG-name"
}

