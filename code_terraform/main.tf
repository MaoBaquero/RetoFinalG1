# Grupo 1 — NetReady: red privada + servidores EC2 + ALB (puntos extra)
# Laboratorio final — Desafío Terraform

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_tag
    Grupo       = var.grupo_tag
    ManagedBy   = "Terraform"
  }
}

# AMI más reciente de Amazon Linux 2 — sin hardcodear ID (requisito del enunciado)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- Red: VPC y subredes ---

resource "aws_vpc" "grupo1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.grupo1.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-subnet-publica"
  })
}

# Segunda subred pública en otra AZ — obligatoria para Application Load Balancer
resource "aws_subnet" "publica_2" {
  vpc_id                  = aws_vpc.grupo1.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-subnet-publica-2"
  })
}

resource "aws_subnet" "privada" {
  vpc_id     = aws_vpc.grupo1.id
  cidr_block = var.private_subnet_cidr

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-subnet-privada"
  })
}

resource "aws_internet_gateway" "grupo1" {
  vpc_id = aws_vpc.grupo1.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.grupo1.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-rt-publica"
  })
}

# Ruta explícita a Internet — sin esto el EC2 no sale aunque exista el IGW
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.grupo1.id
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "publica_2" {
  subnet_id      = aws_subnet.publica_2.id
  route_table_id = aws_route_table.publica.id
}

# --- Security Group EC2: SSH + salida total ---

resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-sg"
  description = "SSH desde Internet y egress completo para servidores NetReady"
  vpc_id      = aws_vpc.grupo1.id

  ingress {
    description = "SSH desde Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Toda la salida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-sg"
  })
}

# --- Dos instancias EC2 en subred pública (base + punto extra) ---

resource "aws_instance" "servidor_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-servidor-1"
  })
}

resource "aws_instance" "servidor_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-servidor-2"
  })
}

# --- Puntos extra: Application Load Balancer ---

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "HTTP entrante para el ALB NetReady"
  vpc_id      = aws_vpc.grupo1.id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Toda la salida hacia las instancias"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-sg-alb"
  })
}

resource "aws_lb" "grupo1" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.publica.id, aws_subnet.publica_2.id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "grupo1" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.grupo1.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.grupo1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grupo1.arn
  }
}

resource "aws_lb_target_group_attachment" "servidor_1" {
  target_group_arn = aws_lb_target_group.grupo1.arn
  target_id        = aws_instance.servidor_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "servidor_2" {
  target_group_arn = aws_lb_target_group.grupo1.arn
  target_id        = aws_instance.servidor_2.id
  port             = 80
}

# Permite tráfico HTTP del ALB hacia los EC2 en el puerto 80
resource "aws_security_group_rule" "ec2_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2.id
  source_security_group_id = aws_security_group.alb.id
  description              = "HTTP desde ALB"
}
