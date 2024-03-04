variable "users" {
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
    groups      = list(string)
  }))
}

variable "groups" {
  type = map(object({
    group_name                      = string
    permission_set_name             = string
    description                     = string
    permission_set_session_duration = string
    inline_policy                   = optional(string)
    managed_policy_arns             = optional(list(string), [])
  }))
}

variable "accounts" {
  type = map(object({
    account_number = string
    groups         = list(string)
    is_management  = optional(bool, false)
  }))
}
