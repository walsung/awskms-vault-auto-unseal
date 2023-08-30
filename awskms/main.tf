resource "aws_kms_key" "vault_unseal_key" {
  description = "KMS key for vault unseal"
  enable_key_rotation = true
  is_enabled = var.enabled
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
}


resource "aws_kms_alias" "vault_unseal_key" {
  name = var.key_alias
  target_key_id = aws_kms_key.vault_unseal_key.key_id
}


resource "aws_iam_policy" "vault_auto_unseal_policy" {
  name = var.vault_auto_unseal_pol.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.vault_unseal_key.arn
      },
    ]
  })
}

resource "aws_iam_user" "vault_auto_unseal_user" {
  name = var.vault_auto_unseal_user.name
}

resource "aws_iam_access_key" "vault_auto_unseal_user" {
  user = aws_iam_user.vault_auto_unseal_user.name
}

resource "aws_iam_user_policy_attachment" "vault_auto_unseal_user_attach" {
  policy_arn = aws_iam_policy.vault_auto_unseal_policy.arn
  user       = aws_iam_user.vault_auto_unseal_user.name
}





resource "aws_iam_role" "vault_auto_unseal_role" {
  name = var.vault_auto_unseal_role.name
  #assume_role_policy = data.aws_iam_policy_document.vault_assume_role.json
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "${var.vault_auto_unseal_role.sid}",
            "Effect": "Allow",
            "Principal": {
                "Service": "cks.kms.amazonaws.com",                  
                "AWS": "${aws_iam_user.vault_auto_unseal_user.arn}"        ## must be ARN
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
  managed_policy_arns = [aws_iam_policy.vault_auto_unseal_policy.arn]
  max_session_duration = 43200                                             ## maximum 12 hours assume role
  tags = "${local.tags}"
}
