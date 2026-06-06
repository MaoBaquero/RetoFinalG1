output "vpc_id" {
  description = "ID de la VPC NetReady"
  value       = aws_vpc.grupo1.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.grupo1.cidr_block
}

output "public_subnet_id" {
  description = "ID de la subred pública"
  value       = aws_subnet.publica.id
}

output "private_subnet_id" {
  description = "ID de la subred privada reservada"
  value       = aws_subnet.privada.id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.grupo1.id
}

output "ec2_servidor_1_public_ip" {
  description = "IP pública del servidor 1"
  value       = aws_instance.servidor_1.public_ip
}

output "ec2_servidor_2_public_ip" {
  description = "IP pública del servidor 2"
  value       = aws_instance.servidor_2.public_ip
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = aws_lb.grupo1.dns_name
}

output "alb_arn" {
  description = "ARN del ALB"
  value       = aws_lb.grupo1.arn
}

output "target_group_arn" {
  description = "ARN del target group"
  value       = aws_lb_target_group.grupo1.arn
}
