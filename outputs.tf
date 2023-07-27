output "aws_instance" {
  description = "The web server id"
  value       = aws_instance.webserver.id
}