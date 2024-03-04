locals {
  group_memberships = flatten([
    for user_key, user in var.users : [
      for group in user.groups : {
        user_key  = user_key
        group_key = group
      }
    ]
  ])

  account_assignements = flatten([
    for account_key, account in var.accounts : [
      for group in account.groups : {
        account_key    = account_key
        group_key      = group
        account_number = account.account_number
      } if !account.is_management
    ]
  ])

  # Filter inline policies only for groups with inline policies specified
  permission_set_inline_policies = { for k, group in var.groups : k => group if group.inline_policy != null }

  # Filter managed policies only for groups with managed policies specified
  managed_policy_attachments = flatten([
    for group_key, group in var.groups : [
      for managed_policy_arn in group.managed_policy_arns : {
        group_key              = group_key
        managed_policy_arn_key = managed_policy_arn
        managed_policy_arn     = managed_policy_arn
      }
    ]
  ])
}
