output "oidc_url" {
  value = module.eks_al2.cluster_oidc_issuer_url
}

output "vpcId" {
  value = module.vpc.vpc_id
}

output "cluster_endpoint" {
  value = module.eks_al2.cluster_endpoint
}

output "cluster_name" {
  value = module.eks_al2.cluster_name
}