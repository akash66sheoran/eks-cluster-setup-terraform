module "eks_al2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name}"
  cluster_version = "1.30"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {
      service_account_role_arn = aws_iam_role.vpc_cni_iam_role.arn
    }
    aws-ebs-csi-driver     = {
      service_account_role_arn = aws_iam_role.ebs_csi_driver_iam_role.arn
    }
    aws-efs-csi-driver     = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2_x86_64"
      instance_types = ["t2.medium"]

      min_size = 2
      max_size = 5
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2
    }
  }

  cluster_endpoint_public_access  = true

  enable_cluster_creator_admin_permissions = true

  tags = local.tags

  depends_on = [ module.vpc ]
}