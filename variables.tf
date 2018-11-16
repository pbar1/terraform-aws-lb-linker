variable "name" {
  description = "Base name to use when naming resouces."
}

variable "tags" {
  description = "A map of tags that should be applied to AWS infrastructure."
  type        = "map"
}

variable "lambda_timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  default     = 300
}

variable "alb_dns_name" {
  description = "The full DNS name (FQDN) of the ALB."
}

variable "alb_listener" {
  description = "The traffic listener port of the ALB."
  default     = "443"
}

variable "s3_bucket" {
  description = "Bucket to track changes between Lambda invocations."
}

variable "nlb_tg_arn" {
  description = "The ARN of the NLBs target group."
}

variable "max_lookup_per_invocation" {
  description = "The max times of DNS look per invocation."
  default     = "50"
}

variable "invocations_before_deregistration" {
  description = "Then number of required Invocations before an IP address is deregistered."
  default     = "3"
}

variable "cw_metric_flag_ip_count" {
  description = "The controller flag that enables the CloudWatch metric of the IP address count."
  default     = "true"
}

variable "event_schedule_expression" {
  description = "How often the lambda runs. For example, `cron(0 20 * * ? *)` or `rate(5 minutes)`."
  default     = "rate(1 minute)"
}
