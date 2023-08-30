####### inputs ###########

variable "region" {
  type = string
  default = "us-east-1"
}

variable "enabled" {
  type = bool
  default = "true"
}

variable "key_alias" {
  type = string
  default = "alias/vault-kms-cmk"
}


variable "vault_auto_unseal_pol" {
  type = object({
    name = string
    description = string
  })

  default = {
    name = "VaultAutoUnsealPol"
    description = "IAM policy that performs hashicorp vault auto unseal"
  }
}


variable "vault_auto_unseal_user" {
  type = object({
    name = string
    description = string
  })

  default = {
    name = "vault_auto_unseal_user"
    description = "IAM user that contains VaultAutoUnsealPol"
  }
}

variable "vault_auto_unseal_role" {
  type = object({
    name = string
    description = string
    sid = string
  })

  default = {
    name = "vault_auto_unseal_role"
    description = "IAM role that assumes role policy to VaultAutoUnsealPol"
    sid = "VaultKMSUnseal"
  }
}

locals {
  tags = {
    app = "vault"
  }
}

####### outputs ##########

output "vault_unseal_iam_user_arn" {
  value = aws_iam_user.vault_auto_unseal_user.arn
}

output "vault_unseal_key_arn" {
  value = aws_kms_key.vault_unseal_key.arn
}

output "vault_unseal_key_alias_arn" {
  value = aws_kms_alias.vault_unseal_key.arn
}

## view the secret access key within tfstate file
output "access_key" {
  value = {
    access_key_id     = aws_iam_access_key.vault_auto_unseal_user.id
    secret_access_key = aws_iam_access_key.vault_auto_unseal_user.secret
  }
  sensitive = true
}

output "role_arn" {
  value = aws_iam_role.vault_auto_unseal_role.arn
}

# output "temporary_credentials" {
#   value = aws_iam_role.vault_auto_unseal_role.arn.apply(arn => aws sts assume-role --role-arn "${arn}" --role-session-name "auto-unseal-role-session")
#   sensitive = true
# }
