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
