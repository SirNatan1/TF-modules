 module "eks" {
   source  = "terraform-aws-modules/eks/aws"
   version = "19.5.1"
   cluster_name                    = "${var.project}-${var.environment}"
   cluster_version                 = var.eks.cluster_version
   cluster_endpoint_private_access = var.eks.cluster_endpoint_private_access
   cluster_endpoint_public_access  = var.eks.cluster_endpoint_public_access

   cluster_addons = {
     coredns = {
       resolve_conflicts = "OVERWRITE"
     }
     kube-proxy = {}
     vpc-cni = {
       resolve_conflicts = "OVERWRITE"
     }
   }

   vpc_id                   = module.vpc.vpc_id
   subnet_ids               = module.vpc.private_subnets

   # Extend node-to-node security group rules
 #  node_security_group_ntp_ipv4_cidr_block = ["169.254.169.123/32"]
   node_security_group_additional_rules = {
#     ingress_self_all = {
#       description = "Node to node all ports/protocols"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       self        = true
#     }
#     egress_all = {
#       description      = "Node all egress"
#       protocol         = "-1"
#       from_port        = 0
#       to_port          = 0
#       type             = "egress"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = ["::/0"]
#     }
#     ingress_allow_access_from_control_plane = {
#       type                          = "ingress"
#       protocol                      = "tcp"
#       from_port                     = 9443
#       to_port                       = 9443
#       source_cluster_security_group = true
#       description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
#     }
     # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
     # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
     # Change this according to your security requirements if needed
#     ingress_cluster_to_node_all_traffic = {
#       description                   = "Cluster API to Nodegroup all traffic"
#       protocol                      = "-1"
#       from_port                     = 0
#       to_port                       = 0
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
   }

   # EKS Managed Node Group(s)
   eks_managed_node_group_defaults = {
     ami_type       = "AL2_x86_64"
     instance_types = var.eks.instance_types
     attach_cluster_primary_security_group = false
   }

   eks_managed_node_groups         = {
     ng-regular = {
       min_size     = 1
       max_size     = 3
       desired_size = 1
       subnet_ids    = [module.vpc.private_subnets[0]]
       instance_types = ["t3.large"]
       capacity_type  = "ON_DEMAND"
       block_device_mappings = {
         xvda = {
           device_name = "/dev/xvda"
           ebs = {
             volume_size           = 50
             volume_type           = "gp2"
             delete_on_termination = true
           }
         }
       }


       update_config = {
         max_unavailable_percentage = 50 # or set `max_unavailable`
       }

     }
     ng-spot = {
       min_size     = 0
       max_size     = 10
       desired_size = 0
       subnet_ids    = [module.vpc.private_subnets[0]]
       instance_types = ["t3.medium"]
       capacity_type  = "SPOT"
       labels = {
         Environment = "staging"
         Capacity    = "on_demand"
       }

       update_config = {
         max_unavailable_percentage = 50 # or set `max_unavailable`
       }

     }
   }
   #kms
   kms_key_administrators = var.eks.kms_key_administrators


   # OIDC Identity provider
   cluster_identity_providers = {
     sts = {
       client_id = "sts.amazonaws.com"
     }
   }

   # aws-auth configmap
   manage_aws_auth_configmap = true

   aws_auth_users = var.eks.aws_auth_users

   tags = local.tags
 }


