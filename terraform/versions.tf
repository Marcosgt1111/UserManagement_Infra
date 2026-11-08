terraform {
  required_version = ">= 1.16"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Etiqueta aplicada em todos os recursos, para achar tudo no console
  default_tags {
    tags = {
      Project   = "usermanagement"
      ManagedBy = "terraform"
    }
  }
}
