module "adot_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  name        = var.ecs_adot_service.service_name
  cluster_arn = module.ecs_cluster.arn

  cpu    = var.ecs_adot_service.cpu
  memory = var.ecs_adot_service.memory

  assign_public_ip         = var.ecs_adot_service.public_ip
  desired_count            = var.ecs_adot_service.desired_count
  autoscaling_min_capacity = var.ecs_adot_service.min_capacity
  autoscaling_max_capacity = var.ecs_adot_service.max_capacity

  runtime_platform = var.ecs_adot_service.runtime_platform
  container_definitions = {
    (var.ecs_adot_service.container_name) = {
      essential                = true
      image                    = var.ecs_adot_service.image
      environment              = concat(var.ecs_adot_service.environment_variables, [])
      secrets                  = []
      port_mappings            = var.ecs_adot_service.port_mappings
      readonly_root_filesystem = var.ecs_adot_service.readonly_root_filesystem
    }
  }

  service_registries = {
    container_name = var.ecs_adot_service.container_name
    registry_arn   = aws_service_discovery_service.services.arn
  }

  subnet_ids = local.vpc_private_subnets

  create_security_group = true
  security_group_rules = {
    udp_2000 = {
      type        = "ingress"
      from_port   = 2000
      to_port     = 2000
      protocol    = "udp"
      description = "XRay service port"
      cidr_blocks = [local.vpc_cidr_block]
    }
    tcp_4318 = {
      type        = "ingress"
      from_port   = 4318
      to_port     = 4318
      protocol    = "tcp"
      description = "otlp service port"
      cidr_blocks = [local.vpc_cidr_block]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  create_task_exec_iam_role = false
  task_exec_iam_role_arn    = module.ecs_cluster.task_exec_iam_role_arn

  create_tasks_iam_role = false
  tasks_iam_role_arn    = aws_iam_role.ecs_task_role.arn

  depends_on = [
    aws_iam_role.ecs_task_role
  ]
}
