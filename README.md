# Terraform AWS Module for managing IAM Identity Center (SSO) users and group permissions
A terraform module to manage AWS SSO users, groups, permissions sets, account and account assignments in organisation AWS managed accounts.
Note that only inline and managed policies are currently supported.
This modules assumes a multi-account AWS organisation is being used and a single IAM Identity Center (SSO) instance has been set up to manage account access across the entire organisation.
This module requires defining `accounts`, `users` and `groups`.
Groups should specify either an inline policy (e.g. with an `aws_iam_policy_document` data block) or an AWS-managed policy, e.g. `"arn:aws:iam::aws:policy/AdministratorAccess"`.

## Usage
If using inline policies, provision them with data blocks, for example:
```terraform
data "aws_iam_policy_document" "deployer" {
  statement {
    actions = [
      "s3:*",
      "ec2:*",
      "rds:*",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "developer" {
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "tester" {
  statement {
    actions = [
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetObject",
      "s3:ListAllMyBuckets",
      "s3:ListAccessPoints",
      "s3:ListBucket",
    ]
    resources = [
      "*"
    ]
  }
}
```

Then use the module to configure the IAM Identity Center user and groups and set inline policies.
Alternatively, use AWS managed policies per the `super_admins` example group below.

```terraform
module "iam_identity_center" {
  source  = "voquis/iam-identity-center/aws"
  version = "0.0.1"

  # AWS Accounts
  accounts = {
    build = {
      account_number = "123456789012"
      groups = [
        "deployers",
        "super_admins",
      ]
    }

    dev = {
      account_number = "234567890123"
      groups = [
        "developers",
        "testers",
        "deployers",
        "super_admins",
      ]
    }

    test = {
      account_number = "345678901234"
      groups = [
        "developers",
        "testers",
        "deployers",
        "super_admins",
      ]
    }

    prod = {
      account_number = "456789012345"
      groups = [
        "deployers",
        "super_admins",
      ]
    }
  }

  # Groups
  groups = {
    deployers = {
      group_name                      = "Deployment Engineers"
      permission_set_name             = "DeploymentEngineer"
      description                     = "Manage all aspects of building and deploying in account"
      permission_set_session_duration = "PT12H"
      inline_policy                   = data.aws_iam_policy_document.deployer.json
    }

    super_admins = {
      group_name                      = "Super Administrators"
      permission_set_name             = "SuperAdministrators"
      description                     = "Super admins with full administrator access to account"
      permission_set_session_duration = "PT2H"
      managed_policy_arns             = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }

    developers = {
      group_name                      = "Developers"
      permission_set_name             = "Developers"
      description                     = "Developers"
      permission_set_session_duration = "PT12H"
      inline_policy                   = data.aws_iam_policy_document.developer.json
    }

    testers = {
      group_name                      = "Testers"
      permission_set_name             = "Testers"
      description                     = "Testers"
      permission_set_session_duration = "PT12H"
      inline_policy                   = data.aws_iam_policy_document.tester.json
    }
  }

  # Users
  users = {
    john_smith = {
      given_name  = "John"
      family_name = "Smith"
      email       = "john.smith@example.com"
      groups      = [
        "developers",
      ]
    }

    jane_smith = {
      given_name  = "Jane"
      family_name = "Smith"
      email       = "jane.smith@example.com"
      groups      = [
        "testers",
      ]
    }

    robert_smith = {
      given_name  = "Robert"
      family_name = "Smith"
      email       = "robert.smith@example.com"
      groups      = [
        "deployers",
        "super_admins",
      ]
    }
  }
}
```

## Notes when using AWS SSO with Terraform
- In v4 of the Terraform AWS provider the registry docs grouping is `SSO Identity Store`, whereas in v3, the data sources are grouped under `Identity Store`.
- Delegating AWS SSO allows some control of SSO, except for the items listed in [this docs page](https://docs.aws.amazon.com/singlesignon/latest/userguide/delegated-admin.html).
For example, when trying to assign permissions to a new account, we experience the following error:
```
You can't assign permission sets provisioned in the management account
You don't have permission to assign permission sets that are provisioned in the management account: account-name (12345678901). Contact the owner of the management account if you need help.
```
The solution is to recreate account assignments in the delegated SSO account.
Note that any account assignments back in to the root/management account are not allowed:
```
Error: error creating SSO Account Assignment for GROUP:
AccessDeniedException: User: arn:aws:iam::12345678901:root is not authorized to perform: sso:CreateAccountAssignment on resource: arn:aws:sso:::account/98765432109
```
- It does not appear possible to read the organisation account ids from the delegated account, meaning that account ids need to be manually referenced.
- Customer managed policies must exist in all organisation account (not managed by SSO) already; SSO does not provision customer managed policies for us, for full automation from SSO, need to use inline policies.
