variable "cidr_block_var" {
  type = map(string)
  default = {
    "main_cidr"      = "10.0.0.0/16"
    "public_cidr"    = "10.0.1.0/24"
    "private_subnet" = "10.0.2.0/24"
    "route_subnet"   = "0.0.0.0/0"
  }
}
# variable "instcount" {
#   default = "3"
# }

variable "az_zone" {
  type = map(string)
  default = {
    "useast1a" = "us-east-1a"
    "useast1b" = "us-east-1b"
    "useast1c" = "us-east-1c"
  }

}

variable "inst_tenancy" {
  default = "default"
}
variable "map_public_ip" {
  #type    = "boolean"
  default = true
}
variable "aws_inst_ami" {
  default = "ami-2757f631"
}

variable "aws_inst_ami_bastionhost" {
  default = "ami-2757f631"
}

variable "aws_inst_inst_type" {
  type    = list(string)
  default = ["t3.medium", "t2.small"]
}
variable "publicip" {
  type    = list(string)
  default = ["182.74.149.46/32", "43.224.159.198/32"]
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/16", "10.0.1.0/24"]
}

variable "associate_public_ip_addrs" {
  default = false
}

