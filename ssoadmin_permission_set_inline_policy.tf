resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = local.permission_set_inline_policies

  inline_policy      = each.value.inline_policy
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}
