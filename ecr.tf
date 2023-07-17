module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"

  count                             = length(var.ecr_appname)
  repository_name                   = lower("${local.common_name}-${var.ecr_appname[count.index]}-ecr")
  attach_repository_policy          = var.ecr_attach_repository_policy_state
  repository_read_write_access_arns = var.ecr_access_role
  repository_lifecycle_policy = jsonencode({
    rules = var.ecr_lifecycle_policy
  })

  tags = local.aws_tags // Apply tags to the ECR module
}
