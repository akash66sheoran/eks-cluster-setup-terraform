terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_al2.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_al2.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = "TOD-eks"
}

provider "kubernetes" {
  host                   = module.eks_al2.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_al2.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}