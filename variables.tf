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
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for worker nodes"
}

variable "control_plane_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for control plane"
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
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Cluster log retention in days"
}
variable "addons_versions" {
  type = object({
    kube_proxy = string
    vpc_cni    = string
    coredns    = string
  })
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

variable "eks_node_additional_iam_roles" {
  description = "Additional policies to attach to the EKS worker nodes IAM role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"]
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
