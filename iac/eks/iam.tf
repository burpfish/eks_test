// iam for master
resource "aws_iam_role" "eks_master" {
  name = "eks_master"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "eks_master_default_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master.name
}

resource "aws_iam_role_policy_attachment" "eks_master_default_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_master.name
}

// iam for worker
resource "aws_iam_role" "eks_worker" {
  name = "eks_worker"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker.name
}

// iam for autoscaler
data "aws_iam_policy_document" "kubernetes_cluster_autoscaler" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

}

resource "aws_iam_policy" "kubernetes_cluster_autoscaler" {
  name        = "${aws_eks_cluster.main.name}-cluster-autoscaler"
  description = "Policy for cluster autoscaler service"

  policy = data.aws_iam_policy_document.kubernetes_cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

// todo: re-enable
//    condition {
//      test     = "StringEquals"
//      variable = "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub"
//      values   = ["system:serviceaccount:kube-system:aws-node"]
//    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "kubernetes_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
  name               = "${aws_eks_cluster.main.name}-aws-node"
}

resource "aws_iam_role_policy_attachment" "kubernetes_cluster_autoscaler" {
  role       = aws_iam_role.kubernetes_cluster_autoscaler.name
  policy_arn = aws_iam_policy.kubernetes_cluster_autoscaler.arn
}