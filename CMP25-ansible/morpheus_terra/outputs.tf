output "public_ip" {
  value       = aws_instance.terra_morpheus.public_ip
  description = "The public IP of the web server"
}
