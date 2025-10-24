resource "aws_s3_bucket" "tempo" {
  bucket = "order-system-monitoring-tempo"

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  rule {
    id     = "ObjectRetentionDays"
    status = "Enabled"
    filter { prefix = "" }
    expiration { days = 7 }
  }
}

resource "aws_iam_role_policy_attachment" "tempo" {
  policy_arn = aws_iam_policy.tempo.arn
  role       = local.node_role_name
}

resource "aws_iam_policy" "tempo" {
  name = "tempo_policy"
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
          "${aws_s3_bucket.tempo.arn}",
          "${aws_s3_bucket.tempo.arn}/*"
        ]
      }
    ]
  })

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}