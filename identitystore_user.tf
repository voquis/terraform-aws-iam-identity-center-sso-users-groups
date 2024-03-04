resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  display_name = "${each.value.given_name} ${each.value.family_name}"
  user_name    = each.value.email

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value = each.value.email
  }
}
