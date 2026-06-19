data "aws_availability_zones" "available" {
  count = var.enable_eks_auto_mode ? 1 : 0

  state = "available"
}

moved {
  from = kubectl_manifest.karpenter_nodeclass
  to   = kubectl_manifest.karpenter_nodeclass[0]
}

resource "kubectl_manifest" "karpenter_nodeclass" {
  count = var.enable_eks_auto_mode ? 1 : 0

  lifecycle {
    precondition {
      condition     = length(trimspace(var.project_name)) > 0
      error_message = "project_name must be set when enable_eks_auto_mode is true."
    }
  }

  yaml_body = <<YAML
apiVersion: eks.amazonaws.com/v1
kind: NodeClass
metadata:
  name: default
spec:
  subnetSelectorTerms:
%{for id in var.subnet_ids~}
  - id: ${id}
%{endfor~}
  securityGroupSelectorTerms:
  - id: ${module.eks.node_security_group_id}
  role: ${module.eks.node_iam_role_name}
  tags:
    Project: ${var.project_name}
    Environment: ${var.environment}
    Application: adp
YAML
}

moved {
  from = kubectl_manifest.karpenter_nodepool
  to   = kubectl_manifest.karpenter_nodepool[0]
}

resource "kubectl_manifest" "karpenter_nodepool" {
  count = var.enable_eks_auto_mode ? 1 : 0

  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  limits:
    cpu: "1000"
    memory: "1000Gi"
  template:
    spec:
      nodeClassRef:
        group: eks.amazonaws.com
        kind: NodeClass
        name: default
      requirements:
      - key: topology.kubernetes.io/zone
        operator: In
        values:
%{for zone in data.aws_availability_zones.available[0].names~}
        - ${zone}
%{endfor~}
      - key: kubernetes.io/arch
        operator: In
        values:
        - amd64
      - key: karpenter.sh/capacity-type
        operator: In
        values:
        - on-demand
        - spot
%{if length(var.karpenter_allowed_instance_types) > 0~}
      - key: node.kubernetes.io/instance-type
        operator: In
        values:
%{for instance in var.karpenter_allowed_instance_types~}
        - ${instance}
%{endfor~}
%{endif~}
YAML
}

moved {
  from = aws_eks_access_entry.karpenter
  to   = aws_eks_access_entry.karpenter[0]
}

resource "aws_eks_access_entry" "karpenter" {
  count = var.enable_eks_auto_mode ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks.node_iam_role_arn
  type          = "EC2"
}

moved {
  from = aws_eks_access_policy_association.karpenter_auto_policy
  to   = aws_eks_access_policy_association.karpenter_auto_policy[0]
}

resource "aws_eks_access_policy_association" "karpenter_auto_policy" {
  count = var.enable_eks_auto_mode ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.karpenter[0].principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.karpenter
  ]
}
