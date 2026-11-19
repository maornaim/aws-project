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

#############


resource "aws_iam_user" "eks_test" {
  name = "eks-test-user"
}
resource "aws_iam_access_key" "eks_test" {
  user = aws_iam_user.eks_test.name
}
resource "aws_eks_access_entry" "eks_test" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_user.eks_test.arn
  type          = "STANDARD"
}


resource "aws_eks_access_policy_association" "eks_test_view" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_user.eks_test.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}
