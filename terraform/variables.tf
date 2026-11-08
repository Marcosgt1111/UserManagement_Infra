variable "aws_region" {
  description = "Região onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tamanho da EC2"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Seu IP público no formato x.x.x.x/32. Só ele pode acessar o SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0)) && endswith(var.my_ip_cidr, "/32")
    error_message = "Use o formato x.x.x.x/32, com um único IP."
  }
}

variable "ssh_public_key_path" {
  description = "Caminho da chave SSH pública (a privada nunca sai da sua máquina)"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "budget_limit_usd" {
  description = "Limite mensal do alerta de gastos, em dólares"
  type        = string
  default     = "10"
}

variable "budget_email" {
  description = "E-mail que recebe o alerta de gastos"
  type        = string
}
