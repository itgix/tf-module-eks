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

variable "addons_versions" {
  type = object({
    kube_proxy = string
    vpc_cni    = string
    coredns    = string
    ebs_csi    = string
  })
}

variable "eks_aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_aws_auth_users" {
  type = list(object({
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_aws_users_path" {
  type        = string
  description = "The organizational path of the user used for building the arn , by default it's just / "
  default     = "/"
}

variable "eks_tags" {
  type    = map(string)
  default = {}
}


################################################################################
# Node group defaults 
################################################################################

variable "eks_ami_type" {
  description = "Default AMI type for the EKS worker nodes"
  type        = string
  default     = "AL2_x86_64"
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

################################################################################
# Karpenter
################################################################################

variable "ec2_spot_service_role" {
  type        = bool
  default     = false
  description = "Configure EC2 spot service role provisioning."
}

