####################
# KMS keys for EKS #
####################
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key for ${var.eks_cluster_name} cluster"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    var.eks_tags,
    tomap({ Name = "${var.eks_cluster_name}-k8s-kms" })
  )
}