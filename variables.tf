################################################################################
# Provider variables
################################################################################

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
}

################################################################################
# Utility variables
################################################################################

variable "environment" {
  type        = string
  description = "Environment in which resources are deployed"
}

variable "project_name" {
  type        = string
  description = "Name of the project, client, or product used to tag EKS Auto Mode nodes"
  default     = ""
}

variable "allow_long_names" {
  type        = string
  default     = true
  description = "Allows longer IAM role names without suffixes. Leave true for new clusters. Set to false for pre-existing clusters to avoid re-creation."
}

################################################################################
# Networking variables
################################################################################

variable "vpc_id" {
  type        = string
  description = "VPC id where EKS is deployed"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for worker nodes"
  default     = [""]
}

variable "control_plane_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for control plane"
  default     = [""]
}

################################################################################
# EKS Cluster Configuration
################################################################################

variable "eks_cluster_name" {
  type        = string
  description = "Desired cluster name"
}

variable "eks_cluster_version" {
  type        = string
  description = "Desired Kubernetes cluster version"
  default     = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs with access to the EKS cluster. Restricted to customer and ITGix"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_enabled_log_types" {
  description = "Log types for CloudWatch logs export from EKS"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Cluster log retention in days"
  default     = 14
}

variable "enable_eks_auto_mode" {
  type        = bool
  description = "Enable EKS Auto Mode instead of the managed node group and standard EKS add-ons"
  default     = false
}

variable "enable_efs_csi" {
  type        = bool
  description = "Enable EFS CSI EKS managed addon and its IRSA role"
  default     = false
}

variable "addons_versions" {
  description = "Configuration of the standard EKS add-ons; versions are required when EKS Auto Mode is disabled"
  type = object({
    kube_proxy                  = optional(string)
    vpc_cni                     = optional(string)
    coredns                     = optional(string)
    ebs_csi                     = optional(string)
    efs_csi                     = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
  })
  default = null

  validation {
    condition = var.enable_eks_auto_mode || try(alltrue([
      for version in [
        var.addons_versions.kube_proxy,
        var.addons_versions.vpc_cni,
        var.addons_versions.coredns,
        var.addons_versions.ebs_csi,
      ] : length(trimspace(version)) > 0
    ]), false)
    error_message = "Normal mode requires non-empty kube_proxy, vpc_cni, coredns, and ebs_csi versions."
  }

  validation {
    condition     = !var.enable_efs_csi || try(length(trimspace(var.addons_versions.efs_csi)) > 0, false)
    error_message = "enable_efs_csi requires a non-empty efs_csi version."
  }

  validation {
    condition     = try(contains(["NONE", "OVERWRITE"], var.addons_versions.resolve_conflicts_on_create), true)
    error_message = "addons_versions.resolve_conflicts_on_create must be one of: NONE, OVERWRITE."
  }
}

variable "eks_tags" {
  type    = map(string)
  default = {}
}

variable "cluster_admins" {
  type = list(
    object({
      username = string
      path     = optional(string, "/users/")
    })
  )
  default = []
}

variable "access_entries" {
  type        = any
  description = "Map of access entries to add to the cluster"
  default     = {}
}

################################################################################
# Node group defaults 
################################################################################

variable "eks_ami_type" {
  description = "Default AMI type for the EKS worker nodes"
  type        = string
  default     = "BOTTLEROCKET_x86_64"
}

variable "eks_disk_size" {
  description = "Disk size of the root volume attached to the EKS worker nodes"
  type        = number
  default     = 50
}

variable "eks_instance_types" {
  description = "EC2 instance types for the EKS worker nodes"
  type        = list(string)
  default     = ["m5a.4xlarge"]
}

variable "eks_volume_type" {
  description = "Type of the root EBS volume attached to the EKS worker nodes"
  type        = string
  default     = "gp3"
}

variable "eks_volume_iops" {
  description = "Number of IOPs on the root EBS volumes"
  type        = number
  default     = 3000
}

variable "eks_node_additional_policies" {
  description = "Additional policies to attach to the EKS worker nodes IAM role"
  type        = map(string)
  default = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "eks_ng_min_size" {
  description = "Minimum number of the worker nodes in the node group"
  type        = number
  default     = 2
}

variable "eks_ng_max_size" {
  description = "Maximum number of the worker nodes in the node group"
  type        = number
  default     = 5
}

variable "eks_ng_desired_size" {
  description = "Desired number of the worker nodes in the node group"
  type        = number
  default     = 2
}

variable "eks_ng_capacity_type" {
  description = "capacity type for node group nodes"
  type        = string
  default     = "SPOT"
}

variable "karpenter_allowed_instance_types" {
  description = "Optional instance types allowed by the EKS Auto Mode NodePool; an empty list applies no instance type restriction"
  type        = list(string)
  default     = []
}

variable "kms_key_enable_default_policy" {
  description = "Specifies whether to enable the default key policy. Defaults to `true`"
  type        = bool
  default     = true
}

variable "kms_key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}
variable "secrets_kms_key_arns" {
  description = "List of Customer Managed KMS Key ARNs for the external secrets service account IAM policy"
  type        = list(string)
}
