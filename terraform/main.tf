terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.95.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

data "aws_availability_zones" "availability_zones" {}

module "eks_network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = var.cidr_block

  azs = data.aws_availability_zones.availability_zones.names
  public_subnets = [
    for i in range(var.num_public_subnets) : cidrsubnet(var.cidr_block, 8, i)
  ]
  private_subnets = [
    for i in range(var.num_private_subnets) : cidrsubnet(var.cidr_block, 8, i + var.num_public_subnets)
  ]

  enable_dns_hostnames = true
  enable_ipv6          = false
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "shared"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks_cluster.cluster_id
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.33"
  subnet_ids      = module.eks_network.private_subnets
  vpc_id          = module.eks_network.vpc_id

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    "node_group_1" = {
      instance_type = var.instance_type
      min_size      = 1
      max_size      = 2
      desired_size  = 1
    }
  }

  tags = {
    Name      = var.cluster_name
    terraform = "true"
  }
}


resource "aws_ecr_repository" "eyego_ecr" {
  name                 = "eyego-nodejs-app"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name      = "eyego-nodejs-app"
    terraform = "true"
  }
}
