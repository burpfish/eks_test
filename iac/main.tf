module network {
  source = "./network"

  tags = var.tags
}

module eks {
  source = "./eks"

  network = module.network
  eks_cluster_name = var.eks_cluster_name
  instance_type = var.instance_type

  tags = var.tags
}

module test_service {
  source = "./test_service"

  ecr_name = "test_service"
}