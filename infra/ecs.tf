/* ECS Cluster */
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}-ecs-cluster"
}

/* ECS Service */
resource "aws_ecs_service" "api" {
  name            = "${var.project}-${var.environment}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    #assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service.id]
    subnets          = module.vpc.private_subnets
  }

  /* Load Balancer configuration */
  load_balancer {
    target_group_arn = aws_alb_target_group.api_alb_target_group.arn
    container_name   = "api"
    container_port   = var.container_port
  }

  lifecycle {
    create_before_destroy = true
  }

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
}

/* Task Definition for ECS */
resource "aws_ecs_task_definition" "api_task" {
  family                   = "api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs-role.arn
  task_role_arn            = aws_iam_role.ecs-role.arn

  container_definitions    = <<DEFINITION
[
  {
    "cpu": 256,
    "memory": 256,
    "image": "${var.api_image}",
    "name": "api",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ],
    "logConfiguration": {
	    "logDriver": "awslogs",
	    "options": {
	        "awslogs-group": "${aws_cloudwatch_log_group.api.name}",
	        "awslogs-region": "${var.AWS_REGION}",
	        "awslogs-stream-prefix": "ecs"
	    }
	}
  }
]
DEFINITION

  depends_on        = [ aws_alb_listener.api_listener ]
}

/* Cloudwatch Log Group */
resource "aws_cloudwatch_log_group" "api" {
  name = "${var.project}-${var.environment}-log-group-api"
}