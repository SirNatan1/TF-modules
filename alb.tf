module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.1"
  name    = local.lb_name

  load_balancer_type = var.lb_type // Specify the type of load balancer

  vpc_id          = local.vpc_id                                 // Set the VPC ID for the ALB
  subnets         = local.vpc_public_subnets                     // Specify the subnets for the ALB
  security_groups = [module.lb_security_group.security_group_id] // Set the security groups for the ALB

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.lb_cert_arn // Specify the ARN of the SSL certificate for HTTPS listener
      target_group_index = 0               // Set the target group index for the HTTPS listener
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  target_groups = [
    for k, v in var.lb_targets_group_and_role_listener :
    {
      name_prefix      = "${k}-tg"
      backend_protocol = lookup(v, "backend_protocol", "HTTP")
      backend_port     = tonumber(lookup(v, "backend_port", 80))
      target_type      = lookup(v, "target_type", "ip")
      health_check = {
        enabled             = tobool(lookup(v, "health_check_enabled", true))                     // Set health check enabled or disabled
        interval            = tonumber(lookup(v, "health_check_interval", 120))                   // Set health check interval
        path                = lookup(v, "health_check_path", "/")                                 // Set the health check path
        port                = tonumber(lookup(v, "health_check_healthy_port", 80))                // Set the health check port
        healthy_threshold   = tonumber(lookup(v, "health_check_healthy_threshold", 3))            // Set the healthy threshold for health checks
        unhealthy_threshold = tonumber(lookup(v, "health_check_healthy_unhealthy_threshold", 10)) // Set the unhealthy threshold for health checks
        timeout             = tonumber(lookup(v, "health_check_healthy_timeout", 119))            // Set the health check timeout
        protocol            = lookup(v, "health_check_healthy_protocol", "HTTP")                  // Set the health check protocol
        matcher             = lookup(v, "http_health_check_code", "200-399")                      // Set the HTTP health check code
      }
    }
  ]

  https_listener_rules = [

    for k, v in var.lb_targets_group_and_role_listener :
    {
      https_listener_index = tonumber(lookup(v, "listener_rules_https_listener_index", 0))
      actions = [
        {
          type = lookup(v, "listener_rules_https_listener_action_type", "forward")
        }
      ]
      conditions = [
        {
          host_headers = [join(".", [lookup(v, "r53_cname"), lookup(v, "r53_zone_name")])] // Set the host headers condition for the listener rule
        }
      ]
    }
  ]

  tags = local.aws_tags // Apply tags to the ALB module
}
