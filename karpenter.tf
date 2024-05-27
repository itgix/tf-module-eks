# Service-linked role for EC2 spot
resource "aws_iam_service_linked_role" "spot" {
  count            = var.ec2_spot_service_role ? 1 : 0
  aws_service_name = "spot.amazonaws.com"
}

## Karpenter
module "karpenter" {
  source                    = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                   = "19.21.0"
  cluster_name              = module.eks.cluster_name
  queue_name                = local.karpenter_queue_name
  queue_managed_sse_enabled = true
  iam_role_arn              = module.eks.eks_managed_node_groups["main"].iam_role_arn
  create_iam_role           = false

  enable_karpenter_instance_profile_creation = true
  irsa_oidc_provider_arn                     = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts            = ["${local.karpenter_namespace}:karpenter"]
  create_irsa                                = true
  irsa_use_name_prefix                       = false
}

