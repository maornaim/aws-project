resource "aws_iam_user" "maor_admin" {
  name = "maor-admin"
}

resource "aws_iam_user_policy_attachment" "maor_admin_administrator" {
  user       = aws_iam_user.maor_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_policy_attachment" "maor_admin_change_password" {
  user       = aws_iam_user.maor_admin.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}