resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = each.value.group_name
  description       = each.value.description
}
