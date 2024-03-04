resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.groups

  name             = each.value.permission_set_name
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = each.value.permission_set_session_duration
}
