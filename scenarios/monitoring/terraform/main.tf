provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudtrail" "monitoring" {
  name                          = "monitoring-trail"
  s3_bucket_name                = aws_s3_bucket.trail_logs.id
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_log_file_validation    = false
}

resource "aws_s3_bucket" "trail_logs" {
  bucket        = "cloudtrail-logs-monitoring"
  force_destroy = true
  acl           = "private"
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Monitoring security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "monitoring" {
  name = "monitoring-cluster"
}

resource "aws_ecs_task_definition" "monitor_task" {
  family                   = "monitor"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([{
    name      = "monitor"
    image     = "alpine:latest"
    cpu       = 256
    memory    = 512
    privileged = true
  }])
}
