resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_master.arn

  vpc_config {
    subnet_ids = var.network.subnets.*.id
    security_group_ids = [ var.network.sg_ingress_from_workstation.id ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_master_default_cluster,
    aws_iam_role_policy_attachment.eks_master_default_service,
    aws_cloudwatch_log_group.eks,
  ]
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_worker.arn

  instance_types = [
    var.instance_type,
  ]

  subnet_ids = var.network.subnets.*.id

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_worker_cni,
    aws_iam_role_policy_attachment.eks_worker_ecr,
  ]

  tags = {
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled" = "TRUE"
  }
}

## OIDC Provider
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com"]
  #  thumbprint_list = concat([data.tls_certificate.cluster.certificates.0.sha1_fingerprint], var.oidc_thumbprint_list)
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

