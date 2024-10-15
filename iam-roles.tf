# =============================================================================================================
#                                       IAM ROLE FOR EBS CSI DRIVER
# =============================================================================================================

data "aws_iam_policy_document" "ebs_csi_driver_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver_iam_role" {
  name               = "TOD-eks-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_iam_role.name
}

# =============================================================================================================
#                                       IAM ROLE FOR VPC CNI
# =============================================================================================================

data "aws_iam_policy_document" "vpc_cni_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
  }
}

resource "aws_iam_role" "vpc_cni_iam_role" {
  name               = "TOD-eks-vpc-cni-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "vpc_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni_iam_role.name
}

# =============================================================================================================
#                                       IAM ROLE FOR ALB ingress controller
# =============================================================================================================

data "aws_iam_policy_document" "aws_load_balancer_controller_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(module.eks_al2.cluster_oidc_issuer_url, "https://", "")}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "alb_ingress_controller_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("AWSLoadBalancerControllerIAMPolicy.json")
}

resource "aws_iam_role" "alb_ingress_controller_role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy_attachment" {
  policy_arn = aws_iam_policy.alb_ingress_controller_policy.arn
  role = aws_iam_role.alb_ingress_controller_role.name
}