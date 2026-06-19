resource "aws_ecs_cluster" "backstage" {
  name = "backstage-demo"
}

resource "aws_ecs_task_definition" "backstage" {
  family                   = "backstage-demo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "1024"
  memory = "2048"

  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "postgres"
      image     = "postgres:16-alpine"
      essential = true
      environment = [
        { name = "POSTGRES_USER", value = "backstage" },
        { name = "POSTGRES_PASSWORD", value = "changemelocal" },
        { name = "POSTGRES_DB", value = "backstage" },
      ]
      
      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -U backstage -d backstage"]
        interval    = 10
        timeout     = 5
        retries     = 5
        startPeriod = 30
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backstage.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "postgres"
        }
      }
    },
    {
      name      = "backstage"
      image     = "${aws_ecr_repository.backstage.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = var.backstage_port, protocol = "tcp" }
      ]
      
      dependsOn = [
        { containerName = "postgres", condition = "HEALTHY" }
      ]
      
      environment = [
        { name = "POSTGRES_HOST", value = "127.0.0.1" },
        { name = "POSTGRES_PORT", value = "5432" },
        { name = "POSTGRES_USER", value = "backstage" },
        { name = "POSTGRES_PASSWORD", value = "changemelocal" },
        { name = "APP_BASE_URL", value = "http://localhost:${var.backstage_port}" },
      ]
      
      secrets = [
        { name = "AUTH_GITHUB_CLIENT_ID", valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/backstage/github_client_id" },
        { name = "AUTH_GITHUB_CLIENT_SECRET", valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/backstage/github_client_secret" },
        { name = "AUTH_GITHUB_TOKEN", valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/backstage/github_token" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backstage.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backstage"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backstage" {
  name            = "backstage-demo"
  cluster         = aws_ecs_cluster.backstage.id
  task_definition = aws_ecs_task_definition.backstage.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.backstage.id]
    assign_public_ip = true
  }
}