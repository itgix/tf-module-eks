data "aws_availability_zones" "available" {
  state = "available"
}

resource "kubectl_manifest" "karpenter_nodeclass" {
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

resource "kubectl_manifest" "karpenter_nodepool" {
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
%{for zone in data.aws_availability_zones.available.names~}
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
YAML
}

resource "aws_eks_access_entry" "karpenter" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks.node_iam_role_arn
  type          = "EC2"
}

resource "aws_eks_access_policy_association" "karpenter_auto_policy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.karpenter.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.karpenter
  ]
}

