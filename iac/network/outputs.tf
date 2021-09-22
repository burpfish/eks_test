output vpc {
  value = aws_vpc.main
}

output subnets {
  value = aws_subnet.main
}

output sg_ingress_from_workstation {
  value = aws_security_group.ingress_from_workstation
}