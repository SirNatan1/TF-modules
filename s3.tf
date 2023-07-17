
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.13.0"

  bucket               = local.s3_bucket_name
  attach_public_policy = false
  attach_policy        = true
  policy               = data.aws_iam_policy_document.s3_bucket_policy.json
  versioning = {
    enabled = var.s3_bucket_versions_enabled
  }
}

resource "aws_iam_user" "s3_user" {
  name = "s3-user"
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_policy" "user_s3_bucket_policy" {
  name = "allow_user_s3_access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${local.s3_bucket_name}/*", "arn:aws:s3:::${local.s3_bucket_name}"]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_s3_policy_attach" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.user_s3_bucket_policy.arn
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.s3_user.arn]
    }

    actions = [
      "s3:*"
    ]

    resources = ["arn:aws:s3:::${local.s3_bucket_name}/*", "arn:aws:s3:::${local.s3_bucket_name}"]
  }
}
