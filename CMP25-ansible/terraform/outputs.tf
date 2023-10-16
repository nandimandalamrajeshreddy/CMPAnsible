output "aws_vpcid" {
  value = aws_vpc.k8main.id
}

output "vpc_cidr_block" {
  value = var.cidr_block_var["main_cidr"]
}

output "instance_tency" {
  value = var.inst_tenancy
}

output "pubsubnet_cidr" {
  value = var.cidr_block_var["public_cidr"]
}

output "privatesubnet_cidr" {
  value = var.cidr_block_var["private_subnet"]
}

output "route_subnet" {
  value = var.cidr_block_var["route_subnet"]
}

output "aws_pubsubnet" {
  value = aws_subnet.k8publicsubnet.id
}

output "aws_pubsubnet1" {
  value = aws_subnet.k8publicsubnet1.id
}

output "aws_privatesubnet" {
  value = aws_subnet.k8privatesubnet.id
}

output "aws_internet_gateway_igw" {
  value = aws_internet_gateway.k8igw.id
}

output "aws_route_table_rpub" {
  value = aws_route_table.k8rpsubnet.id
}

output "aws_route_table_rpub1" {
  value = aws_route_table.k8rpsubnet.id
}

output "aws_route_table_association_routeasscn" {
  value = aws_route_table_association.k8routeasscn.id
}
output "iam_role" {
  value = aws_iam_role.k8_prod.id
}

output "aws_instaprofile" {
  value = aws_iam_instance_profile.k8prod_profile.id
}

output "publicinstance" {
  value = aws_instance.public[*].id
}

output "ec2_global_ips_masterips" {
  value = ["${aws_instance.public.*.public_ip}"]
}

output "ec2_global_ips_bastionhost" {
  value = ["${aws_instance.bastionhost.*.public_ip}"]
}

output "ami" {
  value = var.aws_inst_ami
}

output "inst_type" {
  value = var.aws_inst_inst_type
}

output "aws_sg" {
  value = aws_security_group.k8_sg.id
}
output "elb_name" {
  value = "aws_elb.k8s-elb.id"
}
output "aws_launch_configuration_name" {
  value = "aws_launch_configuration.k8s-launchconfig.id" //NW
}

