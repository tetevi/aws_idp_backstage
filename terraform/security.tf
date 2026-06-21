resource "aws_security_group" "backstage" {
  name        = "backstage-demo"
  description = "Allow Backstage port from a single source and from within the VPC for NLB health checks; allow all egress."
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Backstage UI/API from my IP (client source IP preserved through NLB)"
    from_port   = var.backstage_port
    to_port     = var.backstage_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "NLB health checks originate from within the VPC"
    from_port   = var.backstage_port
    to_port     = var.backstage_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}