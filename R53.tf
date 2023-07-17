module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  for_each  = toset(var.r53_zones)
  zone_name = each.key
  records = [
    for k, v in var.lb_targets_group_and_role_listener :
    {
      name = lookup(v, "r53_cname") // Set the record name from the variable
      type = "A"                    // Set the record type as A (IPv4 address)

      alias = {
        name                   = module.maelys_alb.lb_dns_name // Set the alias target as the ALB DNS name
        zone_id                = module.maelys_alb.lb_zone_id  // Set the alias target zone ID as the ALB zone ID
        evaluate_target_health = true                          // Enable health checks for the alias target
      }
    } if try(v.r53_zone_name == each.key, false) // Filter records based on the zone name

    // Explanation:
    // This block creates a list of records based on the provided variable "targets_group_and_role_listener".
    // Each record is created with a name, type, and an alias target that points to the ALB.
    // The "if" condition filters records by checking if the "r53_zone_name" in the variable matches the current zone being iterated over.

  ]
}
