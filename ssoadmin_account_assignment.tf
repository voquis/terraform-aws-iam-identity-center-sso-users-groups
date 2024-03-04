resource "aws_ssoadmin_account_assignment" "this" {
  for_each = tomap({
    for account_assignment in local.account_assignements : "${account_assignment.account_key}.${account_assignment.group_key}" => account_assignment
  })

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.group_key].arn

  principal_id   = aws_identitystore_group.this[each.value.group_key].group_id
  principal_type = "GROUP"

  target_id   = each.value.account_number
  target_type = "AWS_ACCOUNT"
}
