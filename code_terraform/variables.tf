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
  description = "CIDR de la subred pública principal (EC2 y ALB AZ-a)"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR segunda subred pública — ALB exige mínimo 2 subnets en 2 AZ distintas"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR de la subred privada reservada"
}

variable "availability_zone_a" {
  type        = string
  description = "Zona de disponibilidad para subred pública principal"
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  type        = string
  description = "Zona de disponibilidad para segunda subred pública (ALB)"
  default     = "us-east-1b"
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
