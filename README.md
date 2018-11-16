# AWS LB-Linker Terraform Module 

Terraform module adapted from [this AWS blog post][1]. In short, gives you the ability
to associate a static IP address with an Applicaion Load Balancer (ALB)
using a Network Load Balancer (NLB). This module consists of a Lambda
that periodically runs and resolves the ALB's private IP addresses and
attaches them to the NLB.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb_dns_name | The full DNS name (FQDN) of the ALB. | string | - | yes |
| alb_listener | The traffic listener port of the ALB. | string | `443` | no |
| cw_metric_flag_ip_count | The controller flag that enables the CloudWatch metric of the IP address count. | string | `true` | no |
| event_schedule_expression | How often the lambda runs. For example, `cron(0 20 * * ? *)` or `rate(5 minutes)`. | string | `rate(1 minute)` | no |
| invocations_before_deregistration | Then number of required Invocations before an IP address is deregistered. | string | `3` | no |
| lambda_timeout | The amount of time your Lambda Function has to run in seconds. | string | `300` | no |
| max_lookup_per_invocation | The max times of DNS look per invocation. | string | `50` | no |
| name | Base name to use when naming resouces. | string | - | yes |
| nlb_tg_arn | The ARN of the NLBs target group. | string | - | yes |
| s3_bucket | Bucket to track changes between Lambda invocations. | string | - | yes |
| tags | A map of tags that should be applied to AWS infrastructure. | map | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda_arn | - |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


[1]: https://aws.amazon.com/blogs/networking-and-content-delivery/using-static-ip-addresses-for-application-load-balancers/
