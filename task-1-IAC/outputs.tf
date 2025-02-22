output "public_ip" {
  value       = aws_instance.nginx_server.public_ip
  description = "The public IP address of the Nginx server"
}