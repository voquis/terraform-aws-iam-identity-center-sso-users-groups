output "identitystore_group_membership" {
  value = aws_identitystore_group_membership.this
}

output "identitystore_group" {
  value = aws_identitystore_group.this
}

output "identitystore_user" {
  value = aws_identitystore_user.this
}

output "ssoadmin_account_assignment" {
  value = aws_ssoadmin_account_assignment.this
}

output "ssoadmin_managed_policy_attachment" {
  value = aws_ssoadmin_managed_policy_attachment.this
}

output "ssoadmin_permission_set_inline_policy" {
  value = aws_ssoadmin_permission_set_inline_policy.this
}

output "ssoadmin_permission_set" {
  value = aws_ssoadmin_permission_set.this
}
