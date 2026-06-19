variable "aws_region" {
  description = "AWS region for all resources. us-east-1 is cheapest and matches the Atlanta-adjacent default."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile. Must be the idp-workload SSO profile (account 119233636824)."
  type        = string
  default     = "idp-workload"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository that will hold the Backstage image."
  type        = string
  default     = "backstage"
}

variable "backstage_port" {
  description = "Port the Backstage backend listens on (matches backend.listen :7007)."
  type        = number
  default     = 7007
}

variable "allowed_cidr" {
  description = "CIDR allowed to reach the Backstage port. Set to your /32 public IP for a locked-down demo. Use 0.0.0.0/0 only if your IP is unstable during a recording."
  type        = string
}