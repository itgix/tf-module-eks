data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}
data "aws_eks_cluster_auth" "this" {
  name = mmodule.eks.cluster_name
}
data "aws_caller_identity" "current" {}