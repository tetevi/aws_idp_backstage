resource "aws_security_group" "backstage" {
  name        = "backstage-demo"
  description = "Allow Backstage port from a single source; allow all egress."
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Backstage UI/API"
    from_port   = var.backstage_port
    to_port     = var.backstage_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]

  }

  egress {
    description = "All outbound (GitHub, image pull already done at launch, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}