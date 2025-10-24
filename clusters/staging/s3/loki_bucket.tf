resource "aws_s3_bucket" "loki" {
  bucket = "order-system-monitoring-loki"

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id
  rule {
    id     = "ObjectRetentionDays"
    status = "Enabled"
    filter { prefix = "" }
    expiration { days = 7 }
  }
}

resource "aws_iam_role_policy_attachment" "loki" {
  policy_arn = aws_iam_policy.loki.arn
  role       = local.node_role_name
}

resource "aws_iam_policy" "loki" {
  name = "loki_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        "Resource" : [
          "${aws_s3_bucket.loki.arn}",
          "${aws_s3_bucket.loki.arn}/*"
        ]
      }
    ]
  })

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}