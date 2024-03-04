resource "aws_identitystore_group_membership" "this" {
  for_each = tomap({
    for group_membership in local.group_memberships : "${group_membership.user_key}.${group_membership.group_key}" => group_membership
  })

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.this[each.value.group_key].group_id
  member_id         = aws_identitystore_user.this[each.value.user_key].user_id
}
