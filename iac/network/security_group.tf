resource aws_security_group ingress_from_workstation {
  name        = "ingress_from_workstation"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

data http myip {
  url = "http://ipv4.icanhazip.com"
}

# Allow inbound traffic from local workstation
resource aws_security_group_rule demo-cluster-ingress-workstation-https {
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ingress_from_workstation.id
  to_port           = 443
  type              = "ingress"
}