variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "num_public_subnets" {
  description = "The number of public subnets to create."
  type        = number
  default     = 2
}

variable "num_private_subnets" {
  description = "The number of private subnets to create."
  type        = number
  default     = 2
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}