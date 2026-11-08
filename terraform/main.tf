# Usa a rede padrão que toda conta AWS já tem
data "aws_vpc" "default" {
  default = true
}

# Ubuntu 24.04 mais recente, publicado pela Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deploy" {
  key_name   = "usermanagement-deploy"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# Firewall da EC2
resource "aws_security_group" "app" {
  name        = "usermanagement-app"
  description = "HTTP publico e SSH restrito"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH somente do meu IP"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id
  description       = "Saida liberada (baixar imagens e pacotes)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deploy.key_name
  vpc_security_group_ids = [aws_security_group.app.id]

  # Script executado uma única vez, na primeira inicialização
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  # Exige IMDSv2, a forma protegida de ler os metadados da instância
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "usermanagement-app"
  }
}

# IP fixo: o endereço não muda quando a máquina reinicia
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"
}

resource "aws_budgets_budget" "monthly" {
  name         = "usermanagement-mensal"
  budget_type  = "COST"
  limit_amount = var.budget_limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Sem isto os créditos zeram o custo e o alerta nunca dispara
  cost_types {
    include_credit = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]
  }
}
