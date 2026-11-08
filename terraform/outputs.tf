output "public_ip" {
  description = "IP público da aplicação"
  value       = aws_eip.app.public_ip
}

output "app_url" {
  description = "Endereço da aplicação"
  value       = "http://${aws_eip.app.public_ip}"
}

output "ssh_command" {
  description = "Comando para entrar na EC2"
  value       = "ssh ubuntu@${aws_eip.app.public_ip}"
}
