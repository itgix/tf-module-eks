module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"

  cluster_name                         = var.eks_cluster_name
  cluster_version                      = var.eks_cluster_version
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_security_group_name          = "${var.eks_cluster_name}-sg"
  enable_irsa                          = true

  access_entries = local.merged_access_entries

  ## Control plane logging
  create_cloudwatch_log_group            = true
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention_in_days

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  cluster_compute_config = {
    enabled = true
    #node_pools = ["general-purpose"]
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  cluster_ip_family          = "ipv4"
  create_cni_ipv6_iam_policy = false

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids


  tags                          = var.eks_tags
  kms_key_enable_default_policy = var.kms_key_enable_default_policy
  kms_key_users                 = var.kms_key_users

}
