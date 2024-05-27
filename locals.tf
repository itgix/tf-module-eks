locals {
  karpenter_queue_name           = "queue-${var.aws_region}-${var.environment}-karpenter"
  karpenter_namespace            = "karpenter"
  karpenter_service_account_name = "karpenter"
}

