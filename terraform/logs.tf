resource "aws_cloudwatch_log_group" "backstage" {
  name              = "/ecs/backstage-demo"
  retention_in_days = 7
}