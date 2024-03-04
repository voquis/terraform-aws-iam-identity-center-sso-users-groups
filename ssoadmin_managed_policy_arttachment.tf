resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = tomap({
    for managed_policy_attachment in local.managed_policy_attachments : "${managed_policy_attachment.group_key}.${managed_policy_attachment.managed_policy_arn}" => managed_policy_attachment
  })

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.group_key].arn
}
