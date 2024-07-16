output "security_groups_ingress_ids" {
  value = { for sg in aws_security_group.security_groups_ingress : sg.key => sg.value }
}