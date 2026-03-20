# ============================================================
# AWS Observability Stack
# Includes: CloudWatch, X-Ray, CloudTrail, EventBridge, SNS
# ============================================================

# ============================================================
# SNS Topic for Alarms
# ============================================================
resource "aws_sns_topic" "observability_alerts" {
  name              = "${var.project_name}-${var.environment}-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(local.common_tags, {
    Name = "Observability-Alerts"
  })
}

resource "aws_sns_topic_subscription" "observability_alerts_email" {
  topic_arn = aws_sns_topic.observability_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email

  depends_on = [aws_sns_topic.observability_alerts]
}

# ============================================================
# CloudWatch Log Groups
# ============================================================
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "Application-Logs"
  })
}

resource "aws_cloudwatch_log_group" "alb_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/alb"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "ALB-Logs"
  })
}

resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/rds"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "RDS-Logs"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/vpc-flow-logs"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "VPC-Flow-Logs"
  })
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/${var.project_name}/${var.environment}/lambda"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "Lambda-Logs"
  })
}

# ============================================================
# CloudWatch Log Groups - Regional (Tokyo)
# ============================================================
resource "aws_cloudwatch_log_group" "vpc_flow_logs_tokyo" {
  provider          = aws.tokyo
  name              = "/aws/${var.project_name}/${var.environment}/tokyo/vpc-flow-logs"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name   = "VPC-Flow-Logs-Tokyo"
    Region = "Tokyo"
  })
}

# VPC Flow Logs for Tokyo VPC
resource "aws_flow_log" "tokyo_vpc" {
  provider                = aws.tokyo
  iam_role_arn           = aws_iam_role.vpc_flow_logs_role.arn
  log_destination        = aws_cloudwatch_log_group.vpc_flow_logs_tokyo.arn
  traffic_type           = "ALL"
  vpc_id                 = module.vpc_tokyo.vpc_id
  
  tags = merge(local.common_tags, {
    Name   = "Tokyo-VPC-Flow-Logs"
    Region = "Tokyo"
  })

  depends_on = [aws_cloudwatch_log_group.vpc_flow_logs_tokyo]
}

# ============================================================
# CloudWatch Log Groups - Regional (Taipei)
# ============================================================
resource "aws_cloudwatch_log_group" "vpc_flow_logs_taipei" {
  provider          = aws.taipei
  name              = "/aws/${var.project_name}/${var.environment}/taipei/vpc-flow-logs"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name   = "VPC-Flow-Logs-Taipei"
    Region = "Taipei"
  })
}

# VPC Flow Logs for Taipei VPC
resource "aws_flow_log" "taipei_vpc" {
  provider                = aws.taipei
  iam_role_arn           = aws_iam_role.vpc_flow_logs_role_taipei.arn
  log_destination        = aws_cloudwatch_log_group.vpc_flow_logs_taipei.arn
  traffic_type           = "ALL"
  vpc_id                 = module.vpc_taipei.vpc_id
  
  tags = merge(local.common_tags, {
    Name   = "Taipei-VPC-Flow-Logs"
    Region = "Taipei"
  })

  depends_on = [aws_cloudwatch_log_group.vpc_flow_logs_taipei]
}

# ============================================================
# IAM Role for VPC Flow Logs (Tokyo)
# ============================================================
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.project_name}-vpc-flow-logs-role-tokyo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "VPC-FlowLogs-Role-Tokyo"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.project_name}-vpc-flow-logs-policy-tokyo"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.vpc_flow_logs_tokyo.arn}:*"
    }]
  })
}

# ============================================================
# IAM Role for VPC Flow Logs (Taipei)
# ============================================================
resource "aws_iam_role" "vpc_flow_logs_role_taipei" {
  name = "${var.project_name}-vpc-flow-logs-role-taipei"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "VPC-FlowLogs-Role-Taipei"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy_taipei" {
  name = "${var.project_name}-vpc-flow-logs-policy-taipei"
  role = aws_iam_role.vpc_flow_logs_role_taipei.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.vpc_flow_logs_taipei.arn}:*"
    }]
  })
}

# ============================================================
# X-Ray Groups
# ============================================================
resource "aws_xray_sampling_rule" "default" {
  rule_name      = "${var.project_name}-default"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  attributes = {
    Environment = var.environment
  }
}

resource "aws_xray_sampling_rule" "high_traffic" {
  rule_name      = "${var.project_name}-high-traffic"
  priority       = 100
  version        = 1
  reservoir_size = 10
  fixed_rate     = 0.1
  url_path       = "/api/*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  attributes = {
    Service = "API"
  }
}

# ============================================================
# CloudWatch Dashboards
# ============================================================
resource "aws_cloudwatch_dashboard" "application_overview" {
  dashboard_name = "${var.project_name}-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HealthyHostCount", { stat = "Average" }],
            [".", "UnHealthyHostCount", { stat = "Average" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.tokyo_region
          title  = "ALB Metrics - Tokyo"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average" }],
            [".", "DatabaseConnections", { stat = "Average" }],
            [".", "ReadLatency", { stat = "Average" }],
            [".", "WriteLatency", { stat = "Average" }],
            [".", "FreeableMemory", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.tokyo_region
          title  = "RDS Metrics - Tokyo"
        }
      },
      {
        type = "log"
        properties = {
          query   = "fields @timestamp, @message | stats count() by bin(5m)"
          region  = var.tokyo_region
          title   = "Application Log Volume"
        }
      }
    ]
  })
}

# ============================================================
# CloudWatch Alarms
# ============================================================
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.observability_alerts.arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.project_name}-${var.environment}-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when there are unhealthy hosts"
  alarm_actions       = [aws_sns_topic.observability_alerts.arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_alb_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when ALB response time exceeds 1 second"
  alarm_actions       = [aws_sns_topic.observability_alerts.arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project_name}-${var.environment}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when 5XX error count exceeds 10"
  alarm_actions       = [aws_sns_topic.observability_alerts.arn]
  treat_missing_data  = "notBreaching"
}

# ============================================================
# CloudTrail for API Auditing
# ============================================================
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(local.common_tags, {
    Name = "CloudTrail-Logs"
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail_logs]

  tags = merge(local.common_tags, {
    Name = "Main-Trail"
  })
}

# ============================================================
# EventBridge Rules for Automated Monitoring
# ============================================================
resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name        = "${var.project_name}-instance-state-change"
  description = "Capture EC2 instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["pending", "running", "stopping", "stopped", "shutting-down", "terminated"]
    }
  })

  tags = merge(local.common_tags, {
    Name = "Instance-State-Change"
  })
}

resource "aws_cloudwatch_event_target" "instance_state_sns" {
  rule      = aws_cloudwatch_event_rule.instance_state_change.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.observability_alerts.arn

  input_transformer {
    input_paths = {
      instance   = "$.detail.instance-id"
      state      = "$.detail.state"
      time       = "$.time"
    }
    input_template = "\"EC2 Instance <instance> changed state to <state> at <time>\""
  }
}

resource "aws_cloudwatch_event_rule" "rds_event" {
  name        = "${var.project_name}-rds-events"
  description = "Capture RDS events"

  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["RDS DB Instance Event", "RDS DB Cluster Event"]
  })

  tags = merge(local.common_tags, {
    Name = "RDS-Events"
  })
}

resource "aws_cloudwatch_event_target" "rds_event_sns" {
  rule      = aws_cloudwatch_event_rule.rds_event.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.observability_alerts.arn
}

# ============================================================
# Data Source for AWS Account ID
# ============================================================
data "aws_caller_identity" "current" {}
