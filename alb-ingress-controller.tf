resource "kubernetes_service_account" "alb_ingress_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller_role.arn
    }
  }
}

resource "helm_release" "alb_ingress_controller" {
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"

  set {
    name = "clusterName"
    value = module.eks_al2.cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "region"
    value = "ap-south-1"
  }

  set {
    name = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [ module.eks_al2, kubernetes_service_account.alb_ingress_controller_sa, module.vpc ]
}