data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

resource "aws_iam_role" "github_actions_terraform" {
  name = "maor-devops-github-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:maornaim@141751407/aws-project@1420657374:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    Name    = "maor-devops-github-terraform-role"
    Project = "maor-devops"
  }
}

resource "aws_iam_role_policy" "github_actions_terraform" {
  name = "maor-devops-terraform-permissions"
  role = aws_iam_role.github_actions_terraform.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ManageProjectInfrastructure"
        Effect = "Allow"

        Action = [
          "ec2:*",
          "eks:*",
          "rds:*"
        ]

        Resource = "*"
      },
      {
        Sid    = "ManageTerraformStateBucket"
        Effect = "Allow"

        Action = [
          "s3:*"
        ]

        Resource = [
          "arn:aws:s3:::maor-devops-tfstate-533267148415",
          "arn:aws:s3:::maor-devops-tfstate-533267148415/*"
        ]
      },
      {
        Sid    = "ManageProjectRoles"
        Effect = "Allow"

        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:UpdateAssumeRolePolicy"
        ]

        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/maor-devops-*"
      },
      {
        Sid    = "ManageExistingProjectUsers"
        Effect = "Allow"

        Action = [
          "iam:AttachUserPolicy",
          "iam:CreateAccessKey",
          "iam:CreateUser",
          "iam:DeleteAccessKey",
          "iam:DeleteUser",
          "iam:DetachUserPolicy",
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies",
          "iam:ListUserPolicies",
          "iam:TagUser",
          "iam:UntagUser"
        ]

        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/maor-admin",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/eks-test-user"
        ]
      },
      {
        Sid    = "ManageGitHubOIDCProvider"
        Effect = "Allow"

        Action = [
          "iam:AddClientIDToOpenIDConnectProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:RemoveClientIDFromOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider"
        ]

        Resource = "*"
      }
    ]
  })
}
