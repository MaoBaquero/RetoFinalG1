variable "aws_region" {
  type        = string
  description = "Región AWS de despliegue"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Ambiente: dev o prod"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment debe ser dev o prod."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefijo de nombres de recursos (ej. grupo1-dev)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR de la VPC — dev 10.0.1.0/24, prod 10.0.11.0/24 para no chocar en la misma cuenta"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR de la subred pública"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR de la subred privada reservada"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2"
  default     = "t3.micro"
}

variable "project_tag" {
  type        = string
  description = "Tag Project para auditoría"
  default     = "NetReady"
}

variable "grupo_tag" {
  type        = string
  description = "Número de grupo"
  default     = "1"
}
