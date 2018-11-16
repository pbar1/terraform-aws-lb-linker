resource "aws_lambda_function" "populate_target_group" {
  function_name    = "${var.name}"
  filename         = "${path.module}/populate_NLB_TG_with_ALB.zip"
  handler          = "populate_NLB_TG_with_ALB.lambda_handler"
  source_code_hash = "${base64sha256(file("${path.module}/populate_NLB_TG_with_ALB.zip"))}"
  runtime          = "python2.7"
  timeout          = "${var.lambda_timeout}"
  role             = "${aws_iam_role.lambda_assume_role.arn}"

  environment {
    variables {
      ALB_DNS_NAME                      = "${var.alb_dns_name}"
      ALB_LISTENER                      = "${var.alb_listener}"
      S3_BUCKET                         = "${var.s3_bucket}"
      NLB_TG_ARN                        = "${var.nlb_tg_arn}"
      MAX_LOOKUP_PER_INVOCATION         = "${var.max_lookup_per_invocation}"
      INVOCATIONS_BEFORE_DEREGISTRATION = "${var.invocations_before_deregistration}"
      CW_METRIC_FLAG_IP_COUNT           = "${var.cw_metric_flag_ip_count}"
    }
  }
}

resource "aws_iam_role_policy_attachment" "populate_target_group" {
  role       = "${aws_iam_role.lambda_assume_role.name}"
  policy_arn = "${aws_iam_policy.populate_target_group.arn}"
}

#region IAM Role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_assume_role" {
  name               = "${var.name}-role"
  description        = "Allows Lambda to populate NLB target groups with ALB dynamic IPs"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

#endregion

#region IAM Policy
data "aws_iam_policy_document" "populate_target_group" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
    sid       = "LambdaLogging"
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:PutObject",
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
    ]

    resources = ["*"]
    effect    = "Allow"
    sid       = "S3"
  }

  statement {
    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]

    resources = ["*"]
    effect    = "Allow"
    sid       = "ELB"
  }

  statement {
    actions   = ["cloudwatch:putMetricData"]
    resources = ["*"]
    effect    = "Allow"
    sid       = "CloudWatch"
  }
}

resource "aws_iam_policy" "populate_target_group" {
  name        = "${var.name}-policy"
  description = "Allows Lambda to populate NLB target groups with ALB dynamic IPs"
  policy      = "${data.aws_iam_policy_document.populate_target_group.json}"
}

#endregion

#region CloudWatch
resource "aws_lambda_permission" "populate_target_group" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.populate_target_group.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.populate_target_group.arn}"
}

resource "aws_cloudwatch_event_rule" "populate_target_group" {
  depends_on          = ["aws_lambda_function.populate_target_group"]
  name                = "${var.name}-cwevent"
  description         = "Runs the NLB to ALB linker every minute"
  schedule_expression = "${var.event_schedule_expression}"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "populate_target_group" {
  target_id = "${aws_lambda_function.populate_target_group.function_name}"
  rule      = "${aws_cloudwatch_event_rule.populate_target_group.name}"
  arn       = "${aws_lambda_function.populate_target_group.arn}"
}

#endregion

