module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  ## Control plane logging
  create_cloudwatch_log_group            = true
  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention_in_days

  cluster_addons = {
    coredns = {
      addon_version     = var.addons_versions.coredns
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version = var.addons_versions.kube_proxy
    }
    vpc-cni = {
      addon_version     = var.addons_versions.vpc_cni
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids


  # EKS Managed Node Group(s)

  eks_managed_node_group_defaults = {
    ami_type       = var.eks_ami_type
    disk_size      = var.eks_disk_size
    instance_types = var.eks_instance_types

    iam_role_attach_cni_policy = true

    iam_role_additional_policies = var.eks_node_additional_policies

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = var.eks_disk_size
          volume_type           = var.eks_volume_type
          iops                  = var.eks_volume_iops
          throughput            = 150
          encrypted             = true
          delete_on_termination = true
        }
      }
    }
  }

  eks_managed_node_groups = {
    eks_workers = {
      min_size     = var.eks_ng_min_size
      max_size     = var.eks_ng_max_size
      desired_size = var.eks_ng_desired_size

      ebs_optimized = true

      subnet_ids    = var.subnet_ids
      capacity_type = var.eks_ng_capacity_type
    }
  }

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}
